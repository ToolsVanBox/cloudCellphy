process UpsetPlot {
    tag "UpsetPlot"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/vanboxtelbioinformatics/cellphywrapper:1.0.1':
        'europe-west4-docker.pkg.dev/pmc-gcp-box-d-pip-development/pipeline-containers/cellphywrapper@sha256:1191e1b95fbf1bbc7783b8b40108a30200d79f42b687cbe772a0cee3290c52f2' }"

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