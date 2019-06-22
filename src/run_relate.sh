# m_matschiner Tue Jun 11 00:28:11 CEST 2019

# Make the results directory.
mkdir -p ../res/relate

# Make the log directory.
mkdir -p ../log/relate

# Set the account.
acct=nn9244k

# Launch job to run relate.
for gzvcf in ../res/datasets/r???/t???_{p50000,p200000}_r1e08_3.vcf.gz
do
	# Get names and ids.
	dir=`dirname ${gzvcf}`
	tree_id=`basename ${gzvcf%_3.vcf.gz}`
	res_dir=../res/relate/${tree_id}
	mkdir -p ${res_dir}

	# Set parameters.
	mut_rate="5e-09"
	pop_size=`echo ${tree_id} | cut -d "_" -f 2 | tr -d "p"`
	rec_rate=`echo ${tree_id} | cut -d "_" -f 3 | tr -d "r" | sed 's/e/e-/g'`

	# Run relate.
	out=../log/relate/${tree_id}.out
	rm -f ${out}
	sbatch --account ${acct} -o ${out} run_relate.slurm ${gzvcf} ${res_dir} ${mut_rate} ${pop_size} ${rec_rate}
done