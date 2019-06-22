# m_matschiner Sat Jun 8 23:36:35 CEST 2019

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/datasets

# Simulate trees with the phylsim package.
ruby simulate_trees.rb 20 5 20 ../res/datasets 
