process UNZIP_READS {
    label 'process_long'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'ubuntu:20.04'}"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*uncompressed.fastq'), emit: ch_unzipped_fastq

    // Set a longer execution time limit for this process (e.g., 8 hours)
    time '48h'

    script:
    """
    #!/bin/bash

    # Create an array from the space-separated list
    read -a files <<< "$reads"

    # Define a function to unzip a file
    unzip_file() {
        inputFile="\$1"
        outputFile="\$(dirname \${inputFile})/\$(basename \${inputFile}).uncompressed.fastq"
        gunzip -c \${inputFile} > \${outputFile}
    }

    # Iterate over input files and call the unzip_file function
    for file in "\${files[@]}"; do
        \$(unzip_file "\$file")
    done
    """
}
