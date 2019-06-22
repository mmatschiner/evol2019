# m_matschiner Fri Jun 14 00:11:54 CEST 2019

# Load modules.
module load ruby/2.1.5

# Plot the ratio of estimated versus true node ages.
for analysis in "starbeast" # "beast" "starbeast" "snapp"
do
	for table in ../res/${analysis}/summary/*estimates.txt
	do
		ruby plot_proportional_node_age_errors.rb ${table} ${table%.txt}_ratio.svg
	done
done
