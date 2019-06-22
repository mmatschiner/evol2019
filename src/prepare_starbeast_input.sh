# m_matschiner Mon Jun 10 17:02:15 CEST 2019

# Load modules.
module load ruby/2.2.0
module load python3/3.5.0
module load R/3.4.4

# Add ruby gem directory to path.
export PATH=~/.gem/ruby/2.2.0/bin:${PATH}

# Make the result directory.
mkdir -p ../res/starbeast

# Prepare starbeast input files for each set of alignments.
for phylip in ../res/datasets/r???/*_1_01.phy
do
	# Get names and ids.
	dir=`dirname ${phylip}`
	id=`basename ${phylip%_1_01.phy}`
	tree_id=`echo ${dir} | cut -d "/" -f 4 | tr "r" "t"` # The last part (with tr) is only required temporarily because I should have called the datasets t001 to t020, not r001 to r020.
	res_dir=../res/starbeast/${tree_id}
	mkdir -p ${res_dir}
	res_xml=${res_dir}/${id}.xml

	# Prepare xml if these don't exist yet.
	if [ ! -f ${res_xml} ]
	then
		# Convert the tree to newick format.
		Rscript simplify_tree.r ${dir}/species.tre tmp.starbeast.tre

		# Convert this set of phylip files into nexus format.
		rm -rf tmp_starbeast
		mkdir tmp_starbeast
		cp ${dir}/${id}_1_??.phy tmp_starbeast
		for phylip2 in tmp_starbeast/*.phy
		do
			nex=${phylip2%.phy}.nex
			python3 convert.py ${phylip2} ${nex} -f nexus
		done
		rm tmp_starbeast/*.phy

		# Prepare a file with constraints for all nodes (the only way to fix the species tree topology in starbeast).
		ruby prepare_starbeast_constraints.rb tmp.starbeast.tre ../data/constraints/beast.xml tmp.starbeast.constraints.xml

		# Prepare the xml file with an edited version of beauti.rb (that does not log gene trees).
		ruby beauti_edit.rb -id ${id} -n tmp_starbeast -o ${res_dir} -l 50000000 -c tmp.starbeast.constraints.xml -t tmp.starbeast.tre -m JC -*sl ../data/tables/species_individuals_starbeast.txt

		# Clean up.
		rm tmp.starbeast.tre
		rm tmp.starbeast.constraints.xml
		rm -rf tmp_starbeast
	fi
	exit
done