#!/usr/bin/env nextflow

// Enable DSL2 syntax
nextflow.enable.dsl=2

// Define the input file parameter (default: 'input.txt')
params.input_file = "$baseDir/input.txt"

// Define the output file parameter (default: 'output.txt')
params.output_file = "$baseDir/output.txt"

process catFile {

    // Define the input channel
    input:
    path inputFile

    // Define the output channel
    output:
    path "output.txt"

    // The script to execute
    script:
    """
    cat $inputFile > output.txt
    """
}

workflow {
    // Create a channel for the input file
    input_ch = Channel.fromPath(params.input_file)

    // Execute the process
    catFile(input_ch)
}