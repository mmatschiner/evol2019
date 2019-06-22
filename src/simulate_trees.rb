# m_matschiner Sat Jun 8 23:36:33 CEST 2019

# Load the phylsim and the fileutils libraries.
$libPath = "./phylsim/"
require "./phylsim/main.rb"
require 'fileutils'

# Get the command-line arguments.
number_of_replicates = ARGV[0].to_i
root_age = ARGV[1].to_f
number_of_extant_species = ARGV[2].to_i
res_dir = ARGV[3]

number_of_replicates.times do |x|
	tree = Tree.generate(lambda = 0.6, mu = 0, treeOrigin = root_age, present = 0, k = 0, rootSplit = true, np = number_of_extant_species, npEach = [1,'inf'], checkProbabilities = false, algorithm = "forward", verbose = true, threads = 1)
	dir_name = "#{res_dir}/r#{(x+1).to_s.rjust(3).gsub(" ","0")}"
	FileUtils.mkdir_p("#{dir_name}")
	tree.to_newick(fileName = "#{dir_name}/species.tre", branchLengths = "duration", labels = true, plain = false, includeEmpty = true, overwrite = true, verbose = false)
	tree.dump(fileName = "#{dir_name}/species.dmp", overwrite = false, verbose = false)
end