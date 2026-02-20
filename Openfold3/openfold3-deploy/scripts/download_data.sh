#!/bin/bash
# Orchestrates download of individual database components
# Usage: ./download_data.sh /path/to/download

TARGET_DIR=$1
if [ -z "$TARGET_DIR" ]; then echo "Usage: $0 <TARGET_DIR>"; exit 1; fi

mkdir -p "$TARGET_DIR" && cd "$TARGET_DIR"
BASE_URL="https://raw.githubusercontent.com/aqlaboratory/openfold/main/scripts"

echo "--- STARTING 2.5TB DATABASE SYNC ---"

# List of official download scripts to fetch and run
SCRIPTS=(
  "download_pdb_mmcif.sh"
  "download_pdb70.sh"
  "download_uniref90.sh"
  "download_mgnify.sh"
  "download_uniclust30.sh"
  # "download_bfd.sh" # Uncomment for full BFD (1.7TB)
  "download_small_bfd.sh" # Defaulting to Small BFD for speed
)

for script in "${SCRIPTS[@]}"; do
  echo "Fetching installer: $script"
  wget -qN "$BASE_URL/$script"
  if [ $? -ne 0 ]; then echo " Failed to fetch $script"; exit 1; fi
  
  chmod +x $script
  echo " Running $script..."
  ./$script "$TARGET_DIR"
done

echo "Database Sync Complete."
