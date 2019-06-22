# m_matschiner Wed Jun 12 16:00:34 CEST 2019

# Make the results directory.
mkdir -p ../res/tables

# Write the header to the table.
echo -e "pop_size\trec_rate\tcgene_prob\ttract_prob" > ../res/tables/probs_for_recfree_alignments.txt

# Collect probabilities that alignments of 2000 bp are entirely within one c-gene or single-topology tract.
for html in ../res/datasets/r001/*_1.html
do
	tree_id=`basename ${html%_1.html}`
	pop_size=`echo ${tree_id} | cut -d "_" -f 2`
	rec_rate=`echo ${tree_id} | cut -d "_" -f 3`
	for html2 in ../res/datasets/r0??/t???_${pop_size}_${rec_rate}_1.html
	do
		# This extracts probabilities for 2000 bp alignments, to export 5000 bp alignments, replace "-A 25" with "-A 30".
		cgene_prob=`cat ${html2} | grep -A 25 "Probability that alignment is within one c-gene" | tail -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1`
		tract_prob=`cat ${html2} | grep -A 25 "Probability that alignment is within one tract" | tail -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1`
		echo -e "${pop_size}\t${rec_rate}\t${cgene_prob}\t${tract_prob}" >> ../res/tables/probs_for_recfree_alignments.txt
	done
done
