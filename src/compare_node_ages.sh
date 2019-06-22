# m_matschiner Sat Oct 1 22:37:56 CEST 2016

# Load modules.
module load ruby/2.2.0
module load R/3.4.4

# Prepare summary tables for the three different types of analyses.
for analysis in "beast" "starbeast" # "snapp"
do
	mkdir -p ../res/${analysis}/summary
	for pop_size in "50000" "100000" "200000"
	do
		for rec_rate in "5e09" "1e08" "2e08"
		do
			estimates_file="../res/${analysis}/summary/p${pop_size}_${rec_rate}_${analysis}_estimates.txt"
			if [ ! -f ${estimates_file} ]
			then
				for n in `seq -w 20`
				do
					if [ -f "../res/${analysis}/t0${n}/t0${n}_p${pop_size}_r${rec_rate}.trees" ]
					then
						echo -n "Analyzing t0${n}_p${pop_size}_r${rec_rate}.trees..."
						Rscript simplify_tree.r "../res/datasets/r0${n}/species.tre" "tmp.true.tre" &> /dev/null
						Rscript translate_trees.r "../res/${analysis}/t0${n}/t0${n}_p${pop_size}_r${rec_rate}.trees" "tmp.estimated.trees" &> /dev/null
						ruby compare_node_ages.rb tmp.true.tre tmp.estimated.trees tmp.sampled.trees >> ${estimates_file}
						rm tmp.true.tre
						rm tmp.estimated.trees
						echo " done."
					elif [ -f "../res/${analysis}/t0${n}/t0${n}_p${pop_size}_r${rec_rate}_species.trees" ]
					then
						echo -n "Analyzing t0${n}_p${pop_size}_r${rec_rate}_species.trees..."
						Rscript simplify_tree.r "../res/datasets/r0${n}/species.tre" "tmp.true.tre" &> /dev/null
						Rscript translate_trees.r "../res/${analysis}/t0${n}/t0${n}_p${pop_size}_r${rec_rate}_species.trees" "tmp.estimated.trees" &> /dev/null
						ruby compare_node_ages.rb tmp.true.tre tmp.estimated.trees tmp.sampled.trees >> ${estimates_file}
						rm tmp.true.tre
						rm tmp.estimated.trees
						echo " done."
					else
						echo "ERROR: File with posterior trees could not be found!"
						exit
					fi
				done
			else
				echo "INFO: File ${estimates_file} already present."
			fi
		done
	done
done
