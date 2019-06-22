# m_matschiner Sat Jun 8 21:55:37 CEST 2019

# Check the boundaries that will be used by relate.
bash check_bin_boundaries.sh

# Simulate species trees.
bash simulate_trees.sh

# Run c-genie to calculate distributions of c-genes and topology-breakpoints, to write vcf files and alignment files.
run_c_genie.sh

# Prepare input files for concatenated beast analyses.
bash prepare_beast_input.sh

# Prepare input files for starbeast analyses.
bash prepare_starbeast_input.sh

# Prepare input files for snapp analyses.
bash prepare_snapp_input.sh

# Prepare a table with the mean sizes of c-genes and single-topology tracts.
bash get_mean_cgene_sizes.sh

# Write tables comparing true and estimated node ages.
bash compare_node_ages.sh

# Plot the ratio of estimated versus true node ages.
bash plot_proportional_node_age_errors.sh

# Get the accuracy and precision of age estimates in intervals of 5 time units.
bash get_accuracy_and_precision.sh