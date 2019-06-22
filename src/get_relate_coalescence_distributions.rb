# m_matschiner Tue Jun 11 09:56:08 CEST 2019

# Load the phylsim and the fileutils libraries.
$libPath = "./phylsim/"
require "./phylsim/main.rb"
require 'fileutils'

# Get the command-line arguments.
tree_file_name = ARGV[0]
coalescence_rates_file_name = ARGV[1]
table_file_name = ARGV[2]
generation_time = ARGV[3]
percentile = ARGV[4].to_f

# Parse the tree file.
tree = Tree.parse(fileName = tree_file_name, fileType = "newick", diversityFileName = nil, treeNumber = 0, verbose = false)

# Read the coalescence file.
coalescence_rates_file = File.open(coalescence_rates_file_name)
coalescence_rates_lines = coalescence_rates_file.readlines

# Get the populations.
coalescence_rates_pops = coalescence_rates_lines[0].split

# Get the time bins.
coalescence_rates_time_breaks = coalescence_rates_lines[1].split.map {|i| i.to_f * generation_time}

# Get extant species ids for the two sides of the root.
coalescence_rates_root_node = []
coalescence_rates_time_breaks.size.times { coalescence_rates_root_node << 0 }
extant_species_ids1 = []
extant_species_ids2 = []
tree.branch.each do |b|
	if b.id == "b0"
		b.extantProgenyId.each do |ep|
			tree.branch.each do |bb|
				extant_species_ids1 << bb.speciesId if bb.id == ep
			end
		end
	end
	if b.id == "b1"
		b.extantProgenyId.each do |ep|
			tree.branch.each do |bb|
				extant_species_ids2 << bb.speciesId if bb.id == ep
			end
		end
	end
end
# Get the distributions of coalescence rates between the species on both sides of the root.
extant_species_ids1.each do |e1|
	extant_species_index1 = coalescence_rates_pops.index(e1)
	extant_species_ids2.each do |e2|
		extant_species_index2 = coalescence_rates_pops.index(e2)
		if extant_species_index2 > extant_species_index1
			# Get the coalescence rates for this pair.
			coalescence_rates_this_pair = []
			coalescence_rates_lines[2..-1].each do |l|
				line_ary = l.split
				if line_ary[0] == e1 and line_ary[1] == e2
					line_ary[2..-1].each do |cr|
						coalescence_rates_this_pair << cr.to_f
					end
				end
			end
			# Make sure that coalescence rates were found for this pair.
			if coalescence_rates_this_pair == []
				puts "ERROR: Coalescence rates could not be identified for the species pair #{e1} and #{e2}!"
				exit 1
			end
			# Add the coalescence rates for this pair to the distribution for the root node.
			coalescence_rates_this_pair.size.times do |x|
				coalescence_rates_root_node[x] += coalescence_rates_this_pair[x]
			end
		end
	end
end
# Get the total area under the coalescence-rate distribution.
total_rate_area = 0
(coalescence_rates_root_node.size-1).times do |x|
	time_interval_start = coalescence_rates_time_breaks[0]
	time_interval_end = coalescence_rates_time_breaks[1]
	total_rate_area += (time_interval_end-time_interval_start) * coalescence_rates_root_node[x]
end
threshold_area = percentile * total_rate_area
threshold_time = nil
partial_rate_area = 0
(coalescence_rates_root_node.size-1).times do |x|
	time_interval_start = coalescence_rates_time_breaks[0]
	time_interval_end = coalescence_rates_time_breaks[1]
	partial_rate_area_this_interval = (time_interval_end-time_interval_start) * coalescence_rates_root_node[x]
	if partial_rate_area + partial_rate_area_this_interval > threshold_area
		proportion_this_interval = (threshold_area - partial_rate_area) / partial_rate_area_this_interval
		threshold_time = time_interval_start + proportion_this_interval * (time_interval_end-time_interval_start)
		break
	else
		partial_rate_area += partial_rate_area_this_interval
	end
end
if threshold_time == nil
	puts "ERROR: The time corresponding to a coalescence rate percentile of #{percentile} could not be determined!"
	exit 1
end
puts coalescence_rates_root_node
puts threshold_time
