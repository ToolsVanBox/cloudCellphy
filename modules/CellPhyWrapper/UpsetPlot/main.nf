process UpsetPlot {
    tag "${params.sample_id}"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/vanboxtelbioinformatics/cellphywrapper:1.0.1':
        params.artifact_registry_path + '/cellphywrapper:1.0.1' }"

    publishDir "${params.out}/cellphy/UpsetPlot", mode: 'copy'

    input:
        path(vcfInput)

    output:
        path("${params.sample_id}_all_upset.pdf")
        path("${params.sample_id}_shared_upset.pdf")

    script:
        def PREFIX = params.sample_id
        def OUTGROUP = params.outgroup
        """
        Rscript --vanilla /usr/local/bin/Upsetplot.R ${vcfInput} . ${PREFIX} ${OUTGROUP}
        """

}