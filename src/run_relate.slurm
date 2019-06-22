#!/bin/bash

# m_matschiner Sat Sep 1 18:27:33 CEST 2018
#
# Job name:
#SBATCH --job-name=relate
#
# Wall clock limit:
#SBATCH --time=48:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=30G

## Set up the job environment.
source /cluster/bin/jobsetup
module load relate/1.0.11

## Feedback.
echo
echo "run_relate.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf=${1}
tree_id=`basename ${gzvcf%_3.vcf.gz}`
res_dir=`readlink -f ${2}`
mut_rate=${3}
pop_size=${4}
rec_rate=${5}

# Copy the gzvcf to the temporary directory.
cp ${gzvcf} ${SCRATCH}/${tree_id}.vcf.gz

# Move to the temporary directory.
cd ${SCRATCH}

# Get the path to relate.
relate_bin_path=`which Relate`
relate_path=`echo ${relate_bin_path%/bin/Relate}`
relate_script_path=${relate_path}/scripts


# Write a temporary recombination map.
echo -e "pos\tCOMBINED_rate\tGenetic_Map" > flat.map
echo -e "0\t1\t0" >> flat.map
if [ ${rec_rate} == "5e-09" ]
then
	echo -e "50000000\t0\t25" >> flat.map
elif [ ${rec_rate} == "1e-08" ]
then
	echo -e "50000000\t0\t50" >> flat.map
elif [ ${rec_rate} == "2e-08" ]
then
	echo -e "50000000\t0\t100" >> flat.map
else
	echo "ERROR: Could not parse recombination rate (${rec_rate})."
	exit
fi

# Write a temporary sample table.
echo -e "sample\tpopulation\tgroup\tsex" > samples.txt
for i in `gunzip -c ${tree_id}.vcf.gz | grep "#" | tail -n 1 | cut -f 10-`
do
	echo -e "${i}\t${i}\t${i}\tNA" >> samples.txt
done

# Convert the input data from vcf format to haps/sample format.
RelateFileFormats --mode ConvertFromVcf --haps ${tree_id}.haps --sample ${tree_id}.sample -i ${tree_id}

# Run relate.
Relate --mode All -m ${mut_rate} -N ${pop_size} --haps ${tree_id}.haps --sample ${tree_id}.sample --map flat.map -o ${tree_id}

# Return results.
cp ${tree_id}* ${res_dir}

# Reestimate population sizes and coalescent times.
${relate_script_path}/EstimatePopulationSize/EstimatePopulationSize.sh -i ${tree_id} -m ${mut_rate} --poplabels samples.txt --years_per_gen 1 --threshold 10 -o ${tree_id}.reestimated

# Return results.
cp ${tree_id}.reestimated* ${res_dir}