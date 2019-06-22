# m_matschiner Sat Oct 1 22:47:13 CEST 2016

# Use the phylsim and the fileutils libraries.
$libPath = "./phylsim/"
require "./phylsim/main.rb"
require 'fileutils'

# Add functions to module Enumerable to calculate mean and HPD intervals.
module Enumerable
	def sum
		self.inject(0){|accum, i| accum + i }
	end
	def mean
		if self.length == 0
			nil
		else
			self.sum/self.length.to_f
		end
	end
	def hpd_lower(proportion)
		raise "The interval should be between 0 and 1!" if proportion >= 1 or proportion <= 0
		sorted_array = self.sort
		hpd_index = 0
		min_range = sorted_array[-1]
		diff = (proportion*self.size).round
		(self.size-diff).times do |i|
			min_value = sorted_array[i]
			max_value = sorted_array[i+diff-1]
			range = max_value - min_value
			if range < min_range
				min_range = range
				hpd_index = i
			end
		end
		sorted_array[hpd_index]
	end
	def hpd_upper(proportion)
		raise "The interval should be between 0 and 1!" if proportion >= 1 or proportion <= 0
		sorted_array = self.sort
		hpd_index = 0
		min_range = sorted_array[-1]
		diff = (proportion*self.size).round
		(self.size-diff).times do |i|
			min_value = sorted_array[i]
			max_value = sorted_array[i+diff-1]
			range = max_value - min_value
			if range < min_range
				min_range = range
				hpd_index = i
			end
		end
		sorted_array[hpd_index+diff-1]
	end
end

# Read and parse the true tree.
true_tree_file_name = ARGV[0]
true_tree = Tree.parse(fileName=true_tree_file_name, fileType="newick", diversityFileName = nil, treeNumber = 0, verbose = false)

# Read the estimated trees, and subsample 1000 trees to a new temporary file.
estimated_tree_file_name = ARGV[1]
estimated_tree_file = File.open(estimated_tree_file_name)
estimated_tree_file_lines = estimated_tree_file.readlines
number_of_burning_trees = (estimated_tree_file_lines.size*0.1).to_i
estimated_tree_file_lines = estimated_tree_file_lines[number_of_burning_trees..-1]
estimated_tree_file_lines = estimated_tree_file_lines.sample(1000)
sampled_tree_file_string = ""
estimated_tree_file_lines.each do |l|
	sampled_tree_file_string << "#{l}"
end
sampled_tree_file_name = ARGV[2]
sampled_tree_file = File.open(sampled_tree_file_name,"w")
sampled_tree_file.write(sampled_tree_file_string)
sampled_tree_file.close

# Parse the subsampled trees.
estimated_trees = []
estimated_tree_file_lines.size.times do |x|
	estimated_trees << Tree.parse(fileName=sampled_tree_file_name, fileType="newick", diversityFileName = nil, treeNumber = x, verbose = false)
end

# Prepare arrays for true and estimated node ages.
true_ages = []
estimated_ages_mean = []
estimated_ages_lowerHPD = []
estimated_ages_upperHPD = []

# Get the true and estimated ages of the root node.
true_ages << true_tree.treeOrigin
estimated_ages_of_this_node = []
estimated_trees.each do |t|
	estimated_ages_of_this_node << t.treeOrigin
end
estimated_ages_mean << estimated_ages_of_this_node.mean
estimated_ages_lowerHPD << estimated_ages_of_this_node.hpd_lower(0.95)
estimated_ages_upperHPD << estimated_ages_of_this_node.hpd_upper(0.95)

# Find out which of the branches in the true tree was selected to
# be constrained in the 'young' constraint scheme.
selected_branch = true_tree.branch[0]
true_tree.branch[1..-1].each do |ttb|
	if (ttb.termination-(true_tree.treeOrigin/3.0))**2 < (selected_branch.termination-(true_tree.treeOrigin/3.0))**2
		selected_branch = ttb
	end
end
selected_branch_id = selected_branch.id

# Get the true and estimated ages of all other internal nodes.
true_tree.branch.each do |ttb|
	unless ttb.extant
		# Get the age of this node.
		true_age_of_this_node = ttb.termination
		# Get all extant species of this branch.
		extant_species_ids_for_this_node_in_true_tree = []
		true_tree.branch.each do |ttb2|
			if ttb2.extant
				extant_species_ids_for_this_node_in_true_tree << ttb2.speciesId if ttb.extantProgenyId.include?(ttb2.id)
			end
		end
		estimated_ages_of_this_node = []
		# In all estimated trees, find the branch that has the exact same extant species.
		estimated_trees.each do |et|
			et.branch.each do |etb|
				unless etb.extant
					extant_species_ids_for_this_node_in_estimated_tree = []
					et.branch.each do |etb2|
						if etb2.extant
							extant_species_ids_for_this_node_in_estimated_tree << etb2.speciesId if etb.extantProgenyId.include?(etb2.id)
						end
					end
					if extant_species_ids_for_this_node_in_estimated_tree.sort == extant_species_ids_for_this_node_in_true_tree.sort
						estimated_ages_of_this_node << etb.termination
						break
					end
				end
			end
		end
		true_ages << true_age_of_this_node
		estimated_ages_mean << estimated_ages_of_this_node.mean
		estimated_ages_lowerHPD << estimated_ages_of_this_node.hpd_lower(0.95)
		estimated_ages_upperHPD << estimated_ages_of_this_node.hpd_upper(0.95)
	end
end

# Prepare an output string.
output_string = ""
true_ages.size.times do |x|
	output_string << "#{true_ages[x]}\t#{estimated_ages_mean[x]}\t#{estimated_ages_lowerHPD[x]}\t#{estimated_ages_upperHPD[x]}\n"
end
output_string << "\n"
puts output_string
