# HPC Container Management

This repository contains configurations and scripts for managing High-Performance Computing (HPC) container images, specifically converting Docker images to Singularity Image Format (SIF) files and deploying them to Google Cloud Storage.

## Components:

1.  **`cloudbuild.yaml`**:
    *   Defines a Google Cloud Build pipeline.
    *   **Step 1:** Builds an `apptainer-builder` Docker image using `Dockerfile.builder`.
    *   **Step 2:** Utilizes the `apptainer-builder` to convert specified NVIDIA Docker container images (e.g., OpenMM, NAMD, GROMACS) into Apptainer (Singularity) SIF files.
    *   **Step 3:** Uploads the generated SIF files to a Google Cloud Storage bucket.

2.  **`Dockerfile.builder`**:
    *   A Dockerfile that creates a builder image.
    *   It uses `rockylinux` as a base and installs `apptainer` (Singularity).
    *   This image is used by `cloudbuild.yaml` to perform the Docker-to-SIF conversion.

3.  **`cuda-12.1.0-base-ubuntu22.04.sif`**:
    *   An example (or pre-built) Apptainer/Singularity Image Format (SIF) file.
    *   This particular image is a base for CUDA 12.1.0 on Ubuntu 22.04, indicating the type of HPC images managed by this project.

## Building the Nextflow Container

A separate Cloud Build configuration is provided to build a custom container with Nextflow installed.

### Components:

1.  **`cloudbuild-nextflow.yaml`**:
    *   Defines a Google Cloud Build pipeline to build a container image with Nextflow.
    *   It uses `Dockerfile.cloudshell_nextflow`.
    *   The resulting container is stored in Google Artifact Registry.

2.  **`Dockerfile.cloudshell_nextflow`**:
    *   A Dockerfile that starts from a `gcr.io/cloudshell-images/cloudshell:latest` base image.
    *   It installs the `nextflow` workflow manager.

### Usage:

To build and push the Nextflow container, run the following command:

```bash
gcloud builds submit --config cloudbuild-nextflow.yaml .
```

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Fscientific-computing-examples.git&cloudshell_image=gcr.io%2Fcloudshell-images%2Fcloudshell%3Alatest&cloudshell_working_dir=HPC%2FHCLS&cloudshell_tutorial=README.md)

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Fscientific-computing-examples.git&cloudshell_image=gcr.io%2Fcloudshell-images%2Fcloudshell%3Alatest&cloudshell_working_dir=HPC%2FHCLS&cloudshell_command=gcloud%20builds%20submit%20--config%20cloudbuild-nextflow.yaml%20.)

[![Open in Cloud Shell (Nextflow)](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Fscientific-computing-examples.git&cloudshell_image=us-central1-docker.pkg.dev%2Fai-infra-jrt-1%2Fnvidia-repo%2Fcloudshell-nextflow%3Alatest&cloudshell_working_dir=HPC%2FHCLS&cloudshell_tutorial=README.md)

[link](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGoogleCloudPlatform%2Fscientific-computing-examples.git&cloudshell_image=us-central1-docker.pkg.dev%2Fai-infra-jrt-1%2Fnvidia-repo%2Fcloudshell-nextflow%3Alatest&cloudshell_working_dir=HPC%2FHCLS&cloudshell_tutorial=README.md)

<a href=https://docs.cloud.google.com/shell/docs/"https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2Fusername%2Freponame&cloudshell_image=us-central1-docker.pkg.dev%2Fai-infra-jrt-1%2Fnvidia-repo%2Fcloudshell-nextflow">
<img alt="Open in Cloud Shell" src=https://docs.cloud.google.com/shell/docs/"https://gstatic.com/cloudssh/images/open-btn.svg"></a>