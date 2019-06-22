# m_matschiner Sun Jun 9 00:27:59 CEST 2019

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_too_busy {
    n_jobs=`squeue -u michaelm | wc -l`
    while [ $n_jobs -gt 300 ]
    do
        sleep 10
        n_jobs=`squeue -u michaelm | wc -l`
    done
}

# Make the log directory.
mkdir -p ../log/c_genie

# Set the account.
acct=nn9244k

# Generate simulated datasets for each simulated tree.
for n in `seq -w 20`
do
	tree_dir=../res/datasets/r0${n}
	tree=${tree_dir}/species.tre
	mut_rate="5e-09"
	for pop_size in "50000" "100000" "200000"
	do
		for rec_rate in "5e-09" "1e-08" "2e-08"
		do
			rec_rate_string=`echo ${rec_rate} | tr -d "-"`
			res=${tree_dir}/t0${n}_p${pop_size}_r${rec_rate_string}_1
			if [ ! -f ${res}.html ]
			then
				out=../log/c_genie/t0${n}_p${pop_size}_r${rec_rate_string}_1.out
				rm -f ${out}
				sbatch --account ${acct} -o ${out} --time 48:00:00 --mem-per-cpu 20G run_c_genie.slurm ${tree} ${res} "-n ${pop_size} -g 1 -r ${rec_rate} -l 100000 -t 10000 -a -d -z 20 -s 5000 -u ${mut_rate}"
				sleep_while_too_busy
			fi
			res=${tree_dir}/t0${n}_p${pop_size}_r${rec_rate_string}_2
			if [ ! -f ${res}.vcf.gz ]
			then
				out=../log/c_genie/t0${n}_p${pop_size}_r${rec_rate_string}_2.out
				rm -f ${out}
				sbatch --account ${acct} -o ${out} --time 48:00:00 --mem-per-cpu 20G run_c_genie.slurm ${tree} ${res} "-n ${pop_size} -g 1 -r ${rec_rate} -l 500000 -x -w -d -u ${mut_rate}"
				sleep_while_too_busy
			fi
			res=${tree_dir}/t0${n}_p${pop_size}_r${rec_rate_string}_3
			if [ ! -f ${res}.vcf.gz ]
			then
				out=../log/c_genie/t0${n}_p${pop_size}_r${rec_rate_string}_3.out
				rm -f ${out}
				sbatch --account ${acct} -o ${out} --time 168:00:00 --mem-per-cpu 30G run_c_genie.slurm ${tree} ${res} "-n ${pop_size} -g 1 -r ${rec_rate} -l 50000000 -x -w -d -u ${mut_rate}"
				sleep_while_too_busy
			fi
		done
	done
done