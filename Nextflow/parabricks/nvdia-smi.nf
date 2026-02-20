#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process TEST_GPU {
    // Specify the Parabricks container image
    container 'nvcr.io/nvidia/cuda:12.4.1-base-ubuntu22.04'

    accelerator 1, type: 'nvidia-tesla-t4'

    // Define hardware requirements (optional, depending on executor)
    label 'gpu'

    script:
    """
    echo "Checking GPU visibility inside NVIDIA container..."
    nvidia-smi
    """
}

workflow {
    TEST_GPU()
}