include { BootstrapsCellPhy;SupportCellPhy } from '../modules/phylo'

workflow {
    channel
        .fromPath( params.joint_vcf )
        .set  { joint_vcf }
    channel
        .fromPath( params.best_tree )
        .set  { best_tree }
    channel
        .of( 1..params.n_bootstrap_search )
        .set { bootstrap_idx }
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