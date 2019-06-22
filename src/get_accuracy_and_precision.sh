# m_matschiner Fri Jun 14 00:11:54 CEST 2019

# Load modules.
module load ruby/2.1.5

# Plot the ratio of estimated versus true node ages.
for analysis in "beast" # "starbeast" "snapp"
do
	for table in ../res/${analysis}/summary/*estimates.txt
	do
		ruby get_accuracy_and_precision.rb ${table} ${table%.txt}_accuracies_and_precisions.txt
	done
done
