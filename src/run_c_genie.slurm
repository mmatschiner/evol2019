#!/bin/bash

# m_matschiner Sat Sep 1 18:27:33 CEST 2018
#
# Job name:
#SBATCH --job-name=cgenie
#
# Wall clock limit:
#SBATCH --time=48:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=20G

## Set up the job environment.
source /cluster/bin/jobsetup
module load python3/3.5.0
module load gsl/2.2

## Feedback.
echo
echo "run_c_genie.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
tree=${1}
shift
res=`readlink -f ${1}`
res_base=`basename ${res}`
res_dir=`dirname ${res}`
shift

# Copy the tree to the temporary directory.
cp ${tree} ${SCRATCH}/species.tre

# Move to the temporary directory.
cd ${SCRATCH}

# Download c-genie.
if [ ! -f c-genie ]
then
    wget https://raw.githubusercontent.com/mmatschiner/c-genie/master/c-genie
fi

# Run c-genie.
python3 ./c-genie species.tre ${res_base} "$@"

# Compress the vcf file if there is one.
if [ -f ${res_base}.vcf ]
then
	gzip ${res_base}.vcf
fi

# Return files to the results directory.
cp ${res_base}* ${res_dir}