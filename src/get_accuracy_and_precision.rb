# m_matschiner Fri Jun 14 00:11:55 CEST 2019

# Add statistics to Enumerable.
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
	def sample_variance
		if self.length == 0
			nil
		else
			m = self.mean
			sum = self.inject(0){|accum, i| accum +(i-m)**2 }
			sum/(self.length - 1).to_f
		end
	end
	def standard_deviation
		if self.length == 0
			nil
		else
			return Math.sqrt(self.sample_variance)
		end
	end
	def median
		if self.length == 0
			nil
		else
			sorted_array = self.sort
			if self.size.modulo(2) == 1 
				sorted_array[self.size/2]
			else
				(sorted_array[(self.size/2)-1]+sorted_array[self.size/2])/2.0
			end
		end
	end
end

# Get the command line arguments.
input_table_file_name = ARGV[0]
output_table_file_name = ARGV[1]

# Read the input files.
input_table_file = File.open(input_table_file_name)
input_table_lines = input_table_file.readlines

# Get the accuracies and precisions in intervals of one time unit.
accuracies_0_1 = []
accuracies_1_2 = []
accuracies_2_3 = []
accuracies_3_4 = []
accuracies_4_5 = []
precisions_0_1 = []
precisions_1_2 = []
precisions_2_3 = []
precisions_3_4 = []
precisions_4_5 = []
input_table_lines.each do |l|
	unless l.strip == ""
		line_ary = l.split
		true_age = line_ary[0].to_f
		estimated_age = line_ary[1].to_f
		lower_boundary = line_ary[2].to_f
		upper_boundary = line_ary[3].to_f
		if true_age <= 1
			precisions_0_1 << upper_boundary - lower_boundary
			if true_age >= lower_boundary and true_age <= upper_boundary
				accuracies_0_1 << 1
			else
				accuracies_0_1 << 0
			end
		elsif true_age <= 2
			precisions_1_2 << upper_boundary - lower_boundary
			if true_age >= lower_boundary and true_age <= upper_boundary
				accuracies_1_2 << 1
			else
				accuracies_1_2 << 0
			end
		elsif true_age <= 3
			precisions_2_3 << upper_boundary - lower_boundary
			if true_age >= lower_boundary and true_age <= upper_boundary
				accuracies_2_3 << 1
			else
				accuracies_2_3 << 0
			end
		elsif true_age <= 4
			precisions_3_4 << upper_boundary - lower_boundary
			if true_age >= lower_boundary and true_age <= upper_boundary
				accuracies_3_4 << 1
			else
				accuracies_3_4 << 0
			end
		elsif true_age <= 5
			precisions_4_5 << upper_boundary - lower_boundary
			if true_age >= lower_boundary and true_age <= upper_boundary
				accuracies_4_5 << 1
			else
				accuracies_4_5 << 0
			end
		else
			puts "WARNING: Unexpected true age #{true_age}!"
		end
	end
end

# Prepare the output string.
output_table_string = ""
output_table_string << "0_1\t#{accuracies_0_1.mean}\t#{precisions_0_1.mean}\n"
output_table_string << "1_2\t#{accuracies_1_2.mean}\t#{precisions_1_2.mean}\n"
output_table_string << "2_3\t#{accuracies_2_3.mean}\t#{precisions_2_3.mean}\n"
output_table_string << "3_4\t#{accuracies_3_4.mean}\t#{precisions_3_4.mean}\n"
output_table_string << "4_5\t#{accuracies_4_5.mean}\t#{precisions_4_5.mean}\n"

# Write the output table.
output_table_file = File.open(output_table_file_name, "w")
output_table_file.write(output_table_string)
