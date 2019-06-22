# m_matschiner Mon Jun 10 14:37:19 CEST 2019

# Load modules.
module load ruby/2.1.5
module load python3/3.5.0
module load R/3.4.4

# Make the result directory.
mkdir -p ../res/beast

# Prepare beast input files for each set of alignments.
for phylip in ../res/datasets/r???/*_1_01.phy
do
	# Get names and ids.
	dir=`dirname ${phylip}`
	id=`basename ${phylip%_1_01.phy}`
	tree_id=`echo ${dir} | cut -d "/" -f 4 | tr "r" "t"` # The last part (with tr) is only required temporarily because I should have called the datasets t001 to t020, not r001 to r020.
	res_dir=../res/beast/${tree_id}
	mkdir -p ${res_dir}
	res_xml=${res_dir}/${id}.xml

	# Prepare xml if these don't exist yet.
	if [ ! -f ${res_xml} ]
	then
		# Convert the tree to newick format.
		Rscript simplify_tree.r ${dir}/species.tre tmp.beast.tre

		# Convert this set of phylip files into nexus format.
		mkdir tmp_beast
		cp ${dir}/${id}_1_??.phy tmp_beast
		for phylip2 in tmp_beast/*.phy
		do
			nex=${phylip2%.phy}.nex
			alignment_length=`head -n 1 ${phylip2} | cut -d " " -f 2`
			echo "20 ${alignment_length}" > ${phylip2%.phy}_red.phy
			cat ${phylip2} | grep "_1" | sed "s/_1//g" >> ${phylip2%.phy}_red.phy
			python3 convert.py ${phylip2%.phy}_red.phy ${nex} -f nexus
		done
		rm tmp_beast/*.phy

		# Concatenate all nexus files into a single alignment file.
		ruby concatenate.rb -i tmp_beast/*.nex -o tmp_beast/concatenated.nex -f nexus
		rm tmp_beast/t*.nex

		# Prepare the xml file with an edited version of beauti.rb (that does not log gene trees).
		ruby beauti.rb -id ${id} -n tmp_beast -o ${res_dir} -l 500000 -c ../data/constraints/beast.xml -t tmp.beast.tre -m JC

		# Remove topology operators from the xml file.
		cat ${res_dir}/${id}.xml | grep -v treeSubtreeSlide:Species | grep -v treeExchange:Species > tmp.beast.xml
		cat tmp.beast.xml | grep -v treeNarrowExchange:Species | grep -v treeWilsonBalding:Species > ${res_dir}/${id}.xml
		rm -r tmp_beast
		rm tmp.beast.tre
		rm tmp.beast.xml
	fi
done