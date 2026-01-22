process MLSearchCellPhy {
    if ("${workflow.stubRun}" == "false") {
        memory params.tree_memory
        cpus params.tree_threads
    }
    tag "tree-search"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/zinno/cellphy:latest':
        'europe-west4-docker.pkg.dev/pmc-gcp-box-d-pip-development/pipeline-containers/cloudcellphy@sha256:27dbdaa90d9eb69b86181f54205198e680824881bd206468579d01ad0fca25ba' }"

    publishDir "${params.out}/cellphy/mltrees", mode: 'copy'

    input:
    path(phylo_vcf)
    each tree_search_idx

    output:
    tuple path("${phylo_vcf.simpleName}.CellPhy.${tree_search_idx}.raxml.bestTree"), path("loglikelihood.${tree_search_idx}.txt"), path("${phylo_vcf.simpleName}.CellPhy.${tree_search_idx}.raxml.bestModel")

    script:
    """
    raxml-ng-cellphy-linux \
        --search \
        --seed \$RANDOM \
        --msa ${phylo_vcf} \
        --model ${params.evo_model} \
        --msa-format VCF \
        --prob-msa ${params.prob_msa} \
        --threads ${task.cpus} \
        --prefix ${phylo_vcf.simpleName}.CellPhy.${tree_search_idx} \
        --tree ${params.start_tree_type}{1} \
        --lh-epsilon ${params.lh_epsilon} \

    loglikelihood=\$(grep "Final LogLikelihood" ${phylo_vcf.simpleName}.CellPhy.${tree_search_idx}.raxml.log | awk '{print \$3}')
    echo \$loglikelihood > loglikelihood.${tree_search_idx}.txt

    """
    stub:
    """
    touch ${phylo_vcf.simpleName}.CellPhy.${tree_search_idx}.raxml.bestTree
    awk -v seed=\$RANDOM 'BEGIN{srand(seed);print -rand()}' > loglikelihood.${tree_search_idx}.txt
    """

}

process BootstrapsCellPhy {
    if ("${workflow.stubRun}" == "false") {
        memory params.tree_memory
        cpus params.tree_threads
    }
    tag "tree-validation"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/zinno/cellphy:latest':
        'europe-west4-docker.pkg.dev/pmc-gcp-box-d-pip-development/pipeline-containers/cloudcellphy@sha256:27dbdaa90d9eb69b86181f54205198e680824881bd206468579d01ad0fca25ba' }"

    publishDir "${params.out}/cellphy/bootstraps", mode: 'copy'

    input:
    tuple path(phylo_vcf), path(best_tree), val(bootstrap_search_idx)

    output:
    path("${phylo_vcf.simpleName}.CellPhy.${bootstrap_search_idx}.raxml.bootstraps"), emit: bootstrapTree


    script:
    """
    raxml-ng-cellphy-linux \
        --bootstrap \
        --seed \$RANDOM \
        --msa ${phylo_vcf} \
        --model ${params.evo_model} \
        --msa-format VCF \
        --threads ${task.cpus} \
        --prefix ${phylo_vcf.simpleName}.CellPhy.${bootstrap_search_idx} \
        --bs-trees ${params.bs_trees_per_job} \
        --bs-metric ${params.bs_metric} \


    """
    stub:
    """
    touch ${phylo_vcf.simpleName}.CellPhy.${bootstrap_search_idx}.raxml.bootstraps
    """

}

process SupportCellPhy {
    if ("${workflow.stubRun}" == "false") {
        memory '8 GB'
        cpus 4
    }
    tag "tree-support"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/zinno/cellphy:latest':
        'europe-west4-docker.pkg.dev/pmc-gcp-box-d-pip-development/pipeline-containers/cloudcellphy@sha256:27dbdaa90d9eb69b86181f54205198e680824881bd206468579d01ad0fca25ba' }"

    publishDir "${params.out}/cellphy/support", mode: 'copy'

    input:
    path(best_tree)
    path(all_bootstraps)

    output:
    path("${best_tree.simpleName}.CellPhy.raxml.support"),  emit: supportTree


    script:
    """

    raxml-ng-cellphy-linux \
        --support \
        --threads ${task.cpus} \
        --tree ${best_tree} \
        --prefix ${best_tree.simpleName}.CellPhy \
        --bs-trees ${all_bootstraps} \


    """
    stub:
    """
    touch ${best_tree.simpleName}.CellPhy.raxml.support
    """

}

process MutMapCellPhy {
    tag "Mutmap"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://docker.io/zinno/cellphy:latest':
        'europe-west4-docker.pkg.dev/pmc-gcp-box-d-pip-development/pipeline-containers/cloudcellphy@sha256:27dbdaa90d9eb69b86181f54205198e680824881bd206468579d01ad0fca25ba' }"

    publishDir "${params.out}/cellphy/MutMap", mode: 'copy'

    input: 
    path(phylo_vcf)
    path(best_tree)
    path(best_model)
        
    output:
    path("${best_tree.simpleName}.CellPhy.raxml.mutationMapList"),  emit: mutationMapList
    path("${best_tree.simpleName}.CellPhy.raxml.mutationMapTree"),  emit: mutationMapTree
    path("${best_tree.simpleName}.CellPhy.raxml.startTree"),        emit: startTree
    
    script:
    """

    raxml-ng-cellphy-linux \
        --mutmap \
        --msa ${phylo_vcf} \
        --msa-format VCF \
        --model ${best_model} \
        --tree ${best_tree} \
        --prefix ${best_tree.simpleName}.CellPhy \
        --threads ${task.cpus} \
        --opt-branches off

    """

}