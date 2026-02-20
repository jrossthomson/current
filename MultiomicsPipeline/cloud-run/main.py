import base64
import json
import os
import subprocess
from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["POST"])
def index():
    envelope = request.get_json()
    if not envelope:
        return "Bad Request: no Pub/Sub message received", 400

    pubsub_message = envelope.get("message")
    if not isinstance(pubsub_message, dict) or "data" not in pubsub_message:
        return "Bad Request: invalid Pub/Sub message format", 400

    # Decode the GCS event data
    data = base64.b64decode(pubsub_message["data"]).decode("utf-8")
    event = json.loads(data)
    
    # Extract the bucket and file name
    bucket = event.get("bucket")
    name = event.get("name")
    input_gs_path = f"gs://{bucket}/{name}"

    print(f"bucket: {bucket}")
    print(f"name: {name}")
    print(f"input_gs_path: {input_gs_path}")

    print(f"Triggering Nextflow for file: {input_gs_path}")

    # Define the Nextflow command
    # -bg: runs in background (Cloud Run will still wait for the process to start)
    # -profile google_batch: uses the Cloud Batch executor
    
    scripts_bucket = os.environ.get("SCRIPTS_BUCKET")
    work_bucket = os.environ.get("WORK_BUCKET")
    
    if not scripts_bucket or not work_bucket:
         print("Error: SCRIPTS_BUCKET or WORK_BUCKET environment variables not set.")
         return "Internal Server Error: Missing bucket configuration", 500

    command = [
        "./nextflow", "run", f"gs://{scripts_bucket}/main.nf",
        "-profile", "google_batch",
        "--input", input_gs_path,
        "-work-dir", f"gs://{work_bucket}/workdir/"
    ]

    try:
        # We use Popen so Cloud Run can return a 200 OK quickly 
        # while Nextflow handles the job submission to Batch
        subprocess.Popen(command)
        return f"Pipeline started for {input_gs_path}", 200
    except Exception as e:
        print(f"Error: {e}")
        return "Internal Server Error", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))