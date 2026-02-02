process CellPhyPlotTree {
    tag "${params.sample_id}"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/vanboxtelbioinformatics/cellphywrapper:1.0.1':
        params.artifact_registry_path + '/cellphywrapper:1.0.1' }"

    publishDir "${params.out}/cellphy/CellPhyPlotTree", mode: 'copy'

    input:
        //tuple( 
        path(vcfInput)
        each(percent_idx) 
        //)
        path(mutationMapList)
        path(mutationMapTree)
        path(startTree)
        path(supportTree)


    output:
        path("CPW_Tree_${percent_idx}.pdf")
        path("TreeObject${percent_idx}.RDS")

    script:
        def PTATODIR = params.ptatodir
        def OUTGROUP = params.outgroup
        def PREFIX = params.sample_id

        """
        Rscript --vanilla /usr/local/bin/cellPhyPlotTree.R . ${vcfInput} ${PTATODIR} ${OUTGROUP} ${percent_idx} ${PREFIX}
        """

}