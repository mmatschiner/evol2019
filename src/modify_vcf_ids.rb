# m_matschiner Mon Jun 10 01:34:04 CEST 2019

# Get the command-line argument.
vcf_file_name = ARGV[0]

# Read the vcf file.
vcf_file = File.open(vcf_file_name)
vcf_lines = vcf_file.readlines
vcf_file.close

# Make a new vcf string with modified sample names.
vcf_string = ""
last_selected_pos = nil
vcf_lines.each do |l|
	if l[0..1] == "##"
		vcf_string << l
	elsif l[0] != "#"
		vcf_string << l
	else
		new_line = ""
		line_ary = l.split
		line_ary[0..8].each do |i|
			new_line << "#{i}\t"
		end
		line_ary[9..-1].each do |i|
			new_line << "#{i}_1\t"
		end
		new_line.chomp!("\t")
		new_line << "\n"
		vcf_string << new_line
	end
end

# Rewrite the vcf file with the modified ids.
vcf_file = File.open(vcf_file_name, "w")
vcf_file.write(vcf_string)
