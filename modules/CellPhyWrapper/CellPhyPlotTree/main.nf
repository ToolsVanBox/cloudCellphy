process CellPhyPlotTree {
    tag "CellPhyPlotTree"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/vanboxtelbioinformatics/cellphywrapper:1.0.1':
        'europe-west4-docker.pkg.dev/pmc-gcp-box-d-pip-development/pipeline-containers/cellphywrapper@sha256:1191e1b95fbf1bbc7783b8b40108a30200d79f42b687cbe772a0cee3290c52f2' }"

    publishDir "${params.out}/cellphy/CellPhyPlotTree", mode: 'copy'

    input:
        tuple( 
            path(vcfInput), 
            val(percent_idx) 
        )
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