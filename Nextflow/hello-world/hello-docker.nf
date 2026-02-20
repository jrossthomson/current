#!/usr/bin/env nextflow

process HELLO_WORLD {

    script:
    """
    echo "Nextflow is now running the hello-world container."
    """
}

workflow {
    HELLO_WORLD()
}