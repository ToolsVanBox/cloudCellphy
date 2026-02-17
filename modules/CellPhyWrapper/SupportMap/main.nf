process SupportMap {
    tag "${params.sample_id}"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/vanboxtelbioinformatics/cellphywrapper:1.0.1':
        params.artifact_registry_path + '/cellphywrapper:1.0.1' }"

    publishDir "${params.out}/cellphy/SupportMap", mode: 'copy'

    input:
    path(SupportTree)
    val(OutGroup)

    output:
    path("${SupportTree}.pdf")

    script:
    """
    Rscript /cellphy/script/support-map.R ${SupportTree} ${OutGroup}
    """

}
