#!/bin/bash
set -e
if [ -z "$1" ]; then echo "Usage: ./install_dependencies.sh [PROJECT_ID]"; exit 1; fi

PROJECT_ID=$1
REPO_URL="https://github.com/aqlaboratory/openfold-3.git"
IMAGE_TAG="gcr.io/$PROJECT_ID/openfold3:latest"

echo "--- 1. Cloning OpenFold 3 Repo ---"
rm -rf temp_build && git clone $REPO_URL temp_build && cd temp_build

echo "--- 2. Building Container (Cloud Build) ---"
# This avoids needing Docker locally and handles the massive build size
gcloud builds submit --tag $IMAGE_TAG . --timeout=7200s

echo "Build Complete: $IMAGE_TAG"
rm -rf ../temp_build
