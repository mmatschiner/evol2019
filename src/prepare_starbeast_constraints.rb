# m_matschiner Mon Jun 10 18:17:27 CEST 2019

# Load the phylsim and the fileutils libraries.
$libPath = "./phylsim/"
require "./phylsim/main.rb"
require 'fileutils'

# Get the command-line arguments.
tree_file_name = ARGV[0]
beast_constraint_file_name = ARGV[1]
star_beast_constraint_file_name = ARGV[2]

# Read the constraint file name.
beast_constraint_file = File.open(beast_constraint_file_name)
beast_constraint_lines = beast_constraint_file.readlines
n_spaces = beast_constraint_lines[0].size - beast_constraint_lines[0].strip.size - 1
star_beast_constraint_string = ""
beast_constraint_lines.each do |l|
	star_beast_constraint_string << l
end

# Parse the tree file.
tree = Tree.parse(fileName = tree_file_name, fileType = "newick", diversityFileName = nil, treeNumber = 0, verbose = true)

# Get extant species ids for each branch.
tree.branch.each do |b|
	extant_species_ids = []
	b.extantProgenyId.each do |ep|
		tree.branch.each do |bb|
			extant_species_ids << bb.speciesId if bb.id == ep
		end
	end
	if extant_species_ids.size > 1
		n_spaces.times { star_beast_constraint_string << " " }
		star_beast_constraint_string << "<distribution id=\"#{b.id}.prior\" spec=\"beast.math.distributions.MRCAPrior\" tree=\"@tree.t:Species\"  monophyletic=\"true\">\n"
		n_spaces.times { star_beast_constraint_string << " " }
		star_beast_constraint_string << "        <taxonset id=\"#{b.id}\" spec=\"TaxonSet\">\n"
		extant_species_ids.each do |es|
			n_spaces.times { star_beast_constraint_string << " " }
			star_beast_constraint_string << "                <taxon idref=\"#{es}\"/>\n"
		end
		n_spaces.times { star_beast_constraint_string << " " }
		star_beast_constraint_string << "        </taxonset>\n"
		n_spaces.times { star_beast_constraint_string << " " }
		star_beast_constraint_string << "</distribution>\n"
	end
end

# Write the constraint file for starbeast.
star_beast_constraint_file = File.open(star_beast_constraint_file_name,"w")
star_beast_constraint_file.write(star_beast_constraint_string)