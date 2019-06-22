# m_matschiner Wed Jun 12 00:34:16 CEST 2019

# Launch a beast analysis for each xml file.
for xml in ../res/beast/t???/*.xml
do
	dir=`dirname ${xml}`
	id=`basename ${xml%.xml}`
	cat run_beast.slurm | sed "s/QQQQQQ/${id}/g" > ${dir}/run_beast_${id}.slurm
	cd ${dir}
	sbatch run_beast_${id}.slurm
	cd -
done