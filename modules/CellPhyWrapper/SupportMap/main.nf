process SupportMap {
    tag "SupportMap"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/vanboxtelbioinformatics/cellphywrapper:1.0.1':
        'europe-west4-docker.pkg.dev/pmc-gcp-box-d-pip-development/pipeline-containers/cellphywrapper@sha256:1191e1b95fbf1bbc7783b8b40108a30200d79f42b687cbe772a0cee3290c52f2' }"

    input:
    path(SupportTree)
    val(OutGroup)

    output:
    path("${SupportTree}.pdf")
    // /Users/r.hagelaar/hpc/pmc_vanboxtel/personal/rhagelaar/CellPhyWrapper/TestData/Output/TSites.PB30602.Support.raxml.support.pdf

    script:
    """
    Rscript /cellphy/script/support-map.R ${SupportTree} ${OutGroup}
    """

}
