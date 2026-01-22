nextflow.enable.dsl=2

include { MLSearchCellPhy;BootstrapsCellPhy;SupportCellPhy;MutMapCellPhy } from '../modules/phylo'
include { SupportMap } from '../modules/CellPhyWrapper/SupportMap'
include { CellPhyPlotTree } from '../modules/CellPhyWrapper/CellPhyPlotTree'
include { UpsetPlot } from '../modules/CellPhyWrapper/UpsetPlot'

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


    // Search trees using cellphy 
    MLSearchCellPhy( joint_vcf, tree_search_idx )
    // There should be a smart way of setting this in one statement! 
    MLSearchCellPhy
        .out
        .map { tree, tree_ll, tree_bm -> [ tree, tree_ll.text.toFloat(), tree_bm ]}
        .toSortedList { a, b -> b[1] <=> a[1] }
        .map { it[0][0] }
        .set { best_tree }
    MLSearchCellPhy
        .out
        .map{ tree, tree_ll, tree_bm -> [ tree, tree_ll.text.toFloat(), tree_bm ]}
        .toSortedList { a, b -> b[1] <=> a[1] }
        .map { it[0][2] }
        .set { best_model }

    
    // Bootstrapping the best tree
    joint_vcf
        .combine(best_tree)
        .combine(bootstrap_idx)
        .set { inputs_for_bootstrap }
    BootstrapsCellPhy( inputs_for_bootstrap )
    BootstrapsCellPhy
        .out
        .collectFile( name: 'allBootstraps.txt', newLine: true )
        .set { all_bootstraps }


    // Create support tree 
    SupportCellPhy( best_tree, all_bootstraps)


    // Map mutations to the tree 
    MutMapCellPhy( joint_vcf, best_tree, best_model)


    // Create support map tree 
    SupportCellPhy
        .out
        .set{SupportMapInput}
    SupportMap(SupportMapInput, params.outgroup)


    // Create tree with mutations correctly assigned to branches 
    channel
        .of( (1..10))
        .map { it /10 }
        .set{ percent_idx }
    joint_vcf
        .combine(percent_idx)
        .set {input_CellPhyPlotTree}
    CellPhyPlotTree(
        joint_vcf, 
        percent_idx,
        MutMapCellPhy.out.mutationMapList.first(),
        MutMapCellPhy.out.mutationMapTree.first(),
        MutMapCellPhy.out.startTree.first(),
        SupportCellPhy.out.supportTree.first()
        )
    

    // Create Upset plots 
    UpsetPlot(joint_vcf)
}