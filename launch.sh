#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --job-name=nextflow
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=R.Hagelaar@prinsesmaximacentrum.nl
#SBATCH --output=cloudCellphy-log_%j.out


module load java
module load nextflow/24.10.5

if [ ! -d $PWD/nxf-scratch ]; then
    mkdir $PWD/nxf-scratch
fi

export NXF_TEMP=$PWD/nxf-scratch

nextflow workflows/cloudCellphy.nf -profile hpc -c configs/run.config -resume
