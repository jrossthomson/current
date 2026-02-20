FROM eclipse-temurin:17-jdk-focal

# Install dependencies and Nextflow
RUN apt-get update && apt-get install -y curl procps python3 python3-pip \
    && curl -s https://get.nextflow.io | bash \
    && chmod +x nextflow

# Copy the launcher script
COPY main.py .
COPY nextflow.config .
COPY your-pipeline/ your-pipeline/
RUN pip3 install flask google-cloud-pubsub

# Run the web service
CMD ["python3", "main.py"]