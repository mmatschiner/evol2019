# m_matschiner Wed Jun 12 13:41:26 CEST 2019

# Make the results directory.
mkdir -p ../res/tables

# Write the header to the table.
echo -e "pop_size\trec_rate\tcgene_size\ttract_size" > ../res/tables/mean_sizes.txt

# Collect mean sizes of c-genes and single-topology tracts.
for html in ../res/datasets/r001/*_1.html
do
	tree_id=`basename ${html%_1.html}`
	pop_size=`echo ${tree_id} | cut -d "_" -f 2`
	rec_rate=`echo ${tree_id} | cut -d "_" -f 3`
	for html2 in ../res/datasets/r0??/t???_${pop_size}_${rec_rate}_1.html
	do
		mean_cgene_size=`cat ${html2} | grep -A 1 "Mean c-gene size" | tail -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1`
		mean_tract_size=`cat ${html2} | grep -A 1 "Mean tract size" | tail -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1`
		echo -e "${pop_size}\t${rec_rate}\t${mean_cgene_size}\t${mean_tract_size}" >> ../res/tables/mean_sizes.txt
	done
done
