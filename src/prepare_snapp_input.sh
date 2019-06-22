# m_matschiner Mon Jun 10 01:03:12 CEST 2019

# Load modules.
module load ruby/2.1.5
module load R/3.4.4

# Make the results directory.
mkdir -p ../res/snapp/

# Download the snapp_prep.rb script if it is not present yet.
if [ ! -f snapp_prep.rb ]
then
	wget https://raw.githubusercontent.com/mmatschiner/snapp_prep/master/snapp_prep.rb
fi

# Prepare snapp input files for each vcf.
for gzvcf in ../res/datasets/r???/*_2.vcf.gz
do
	# Get names and ids.
	dir=`dirname ${gzvcf}`
	id=`basename ${gzvcf%_2.vcf.gz}`
	tree_id=`echo ${dir} | cut -d "/" -f 4 | tr "r" "t"` # The last part (with tr) is only required temporarily because I should have called the datasets t001 to t020, not r001 to r020.
	res_dir=../res/snapp/${tree_id}
	mkdir -p ${res_dir}
	res_xml=${res_dir}/${id}.xml

	# Prepare xml if these don't exist yet.
	if [ ! -f ${res_xml} ]
	then
		# Convert the tree to newick format.
		Rscript simplify_tree.r ${dir}/species.tre tmp.snapp.tre

		# Replace sample ids in the vcf file.
		gunzip -c ${gzvcf} > tmp.vcf
		ruby modify_vcf_ids.rb tmp.vcf
		ruby snapp_prep.rb -v tmp.vcf -c ../data/constraints/snapp.txt -t ../data/tables/species_individuals.txt -s tmp.snapp.tre -m 5000 -w 0 -l 1000000 -x ${res_dir}/${id}.xml -o ${id}

		# Clean up.
		rm -f tmp.vcf
		rm -f tmp.snapp.tre
	fi
done