# m_matschiner Sat Oct 1 23:05:45 CEST 2016

# Load the phytools library.
library(phytools)

# Get the command line arguments.
args <- commandArgs(trailingOnly = TRUE)
input_trees_file_name <- args[1]
output_trees_file_name <- args[2]

# Read the Nexus trees file.
trees <- read.nexus(input_trees_file_name)

# Write the Newick trees file.
write.tree(trees,output_trees_file_name)
