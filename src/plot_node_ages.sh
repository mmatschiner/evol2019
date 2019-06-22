# m_matschiner Sun Oct 2 01:22:20 CEST 2016

# Load modules.
module load ruby/2.1.5

# Plot the true and estimated node ages for all analyses.
for analysis in "beast" # "starbeast" "snapp"
do
	for table in ../res/${analysis}/summary/*estimates.txt
	do
		ruby plot_node_ages.rb ${table} ${table%.txt}.svg ${table%.txt}_stats.txt
	done
done
