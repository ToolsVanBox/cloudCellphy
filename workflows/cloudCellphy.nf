include { MLSearchCellPhy;BootstrapsCellPhy;SupportCellPhy } from '../modules/phylo'

workflow {
    channel
        .fromPath( params.joint_vcf )
        .set  { joint_vcf }
    channel
        .of( 1..params.n_tree_search )
        .set { tree_search_idx }
    channel
        .of( 1..params.n_bootstrap_search )
        .set { bootstrap_idx }
    MLSearchCellPhy( joint_vcf, tree_search_idx )
    MLSearchCellPhy
        .out
        .map { tree, tree_ll -> [ tree, tree_ll.text.toFloat() ]}
        .toSortedList { a, b -> b[1] <=> a[1] }
        .map { it[0][0] }
        .set { best_tree }
    joint_vcf
        .combine(best_tree)
        .combine(bootstrap_idx)
        .set { inputs_for_bootstrap }
    BootstrapsCellPhy( inputs_for_bootstrap )
    BootstrapsCellPhy
        .out
        .collectFile( name: 'allBootstraps.txt', newLine: true )
        .set { all_bootstraps }
    SupportCellPhy( best_tree, all_bootstraps)
}