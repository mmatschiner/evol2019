# m_matschiner Wed Jun 12 01:05:02 CEST 2019

# Launch a beast analysis for each xml file.
for xml in ../res/snapp/t???/*.xml
do
	dir=`dirname ${xml}`
	id=`basename ${xml%.xml}`
	cat run_snapp.slurm | sed "s/QQQQQQ/${id}/g" > ${dir}/run_snapp_${id}.slurm
	cd ${dir}
	sbatch run_snapp_${id}.slurm
	cd -
done