# Master Deployment Guide: OpenFold 3 (Offline Edition)

## Target Audience: DevOps / Cloud Architects

## Objective: Deploy a secured, air-gapped capable OpenFold 3 pipeline on Google Cloud.

## Deliverable: A complete GitHub repository structure that sets up Infrastructure, Data, and Inference.

## Execution Steps (For the Client)

1.  **Clone Repo**: `git clone ...`
2.  **Deploy Infra**: Run `ghpc create` and `ghpc deploy` from the `infrastructure/` folder.
3.  **Build Engine**: Run `./scripts/install_dependencies.sh YOUR_PROJECT_ID`.
4.  **Sync Data**:
    *   Upload the downloader: `kubectl create configmap download-script --from-file=scripts/download_data.sh`
    *   Run the job: `kubectl apply -f scripts/02-mirror-job.yaml`
    *   **WAIT 6-12 HOURS**.
5.  **Run Inference**:
    *   Upload input: `kubectl create configmap input-data --from-file=your_input.json`
    *   Upload repair tool: `kubectl create configmap repair-script --from-file=scripts/repair_json.py`
    *   Start Job: `kubectl apply -f manifests/03-production-run.yaml`
6.  **Get Results**: `kubectl cp result-retriever:/usr/share/nginx/html/results ./local_results`
