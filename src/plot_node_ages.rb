# m_matschiner Sun Oct 2 01:22:20 CEST 2016

# Add methods to module Enumerable to calculate the mean of an array.
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
end

# Read the summary file for true and estimated node ages.
estimates_file_name = ARGV[0]
estimates_file = File.open(estimates_file_name)
estimates_lines = estimates_file.readlines
true_ages = []
estimated_ages_means = []
estimated_ages_lowers = []
estimated_ages_uppers = []
estimates_lines.each do |l|
	unless l.strip == ""
		line_ary = l.split
		true_ages << line_ary[0].to_f
		estimated_ages_means << line_ary[1].to_f
		estimated_ages_lowers << line_ary[2].to_f
		estimated_ages_uppers << line_ary[3].to_f
	end
end

# Some specifications for the SVG output.
dimX = 600
dimY = 600
max_age = 5
cr = 6
line_width = 2
frame_stroke_width = 2
dot_color = "grey"
dot_constraint_color = "red"
dot_alpha = 1.0
hpd_color = "grey"
hpd_constraint_color = "red"
hpd_alpha = 0.5
hpd_width = 4.0
font_family = "Helvetica"
font_size = 14
text_x = 20

# Initiate the stats output.
stats_output = ""

# Prepare the header of the SVG string.
svg_output = ""
svg_output << "<?xml version=\"1.0\" standalone=\"no\"?>\n"
svg_output << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\" \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">\n"
svg_output << "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"#{dimX}\" height=\"#{dimY}\" viewBox=\"0 0 #{dimX} #{dimY}\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n"
svg_output << "\n"

# Write some style definitions.
svg_output << "  <defs>\n"
svg_output << "    <circle id=\"dot\" cx=\"0\" cy=\"0\" r=\"#{cr}\" fill=\"#{dot_color}\" fill-opacity=\"#{dot_alpha}\" />\n"
svg_output << "    <circle id=\"dot_constraint\" cx=\"0\" cy=\"0\" r=\"#{cr}\" fill=\"#{dot_constraint_color}\" fill-opacity=\"#{dot_alpha}\" />\n"
svg_output << "    <path id=\"hpd\" cx=\"0\" cy=\"0\" stroke=\"#{hpd_color}\" stroke-width=\"#{hpd_width}\" stroke-opacity=\"#{hpd_alpha}\" />\n"
svg_output << "  </defs>\n"
svg_output << "\n"

# Write the frame.
svg_output << "  <!--Frame-->\n"
svg_output << "  <rect style=\"stroke:black; stroke-width:#{frame_stroke_width/2.0}px; fill:none\" x=\"0\" y=\"0\" width=\"#{dimX}\" height=\"#{dimY}\" />\n"
svg_output << "\n"

# Write bars and dots for estimated nodes.
svg_output << "  <!--estimated nodes-->\n"
true_ages.size.times do |x|
	cx = ((true_ages[x]/max_age.to_f)*dimX)
	cy_lower = dimY-((estimated_ages_lowers[x]/max_age.to_f)*dimY)
	cy_upper = dimY-((estimated_ages_uppers[x]/max_age.to_f)*dimY)
	svg_output << "  <path id=\"hpd\" style=\"stroke:#{hpd_color}; stroke-width:#{hpd_width}px; stroke-opacity:#{hpd_alpha}\" d=\"M #{cx},#{cy_lower} L #{cx},#{cy_upper}\" />\n"
end
true_ages.size.times do |x|
	cx = ((true_ages[x]/max_age.to_f)*dimX)
	cy = dimY-((estimated_ages_means[x]/max_age.to_f)*dimY)
	svg_output << "  <use x=\"#{cx}\" y=\"#{cy}\" xlink:href=\"#dot\"/>\n"
end
svg_output << "\n"

# Write the optimum line.
svg_output << "  <!--Optimum-->\n"
svg_output << "  <path id=\"optimum\" style=\"fill:none; stroke:black; stroke-width:#{line_width}px\" stroke-dasharray=\"10,10\" d=\"M 0,#{dimY} L #{dimX},0\" />\n"
svg_output << "\n"

# Calculate the proportion of true ages that is lower than, within, or greater than the 95% HPD interval.
lower_than_hpd = 0
inside_hpd = 0
greater_than_hpd = 0
true_ages.size.times do |a|
	if estimated_ages_uppers[a] < true_ages[a]
		greater_than_hpd += 1
	elsif estimated_ages_uppers[a] >= true_ages[a] and estimated_ages_lowers[a] <= true_ages[a]
		inside_hpd += 1
	elsif estimated_ages_lowers[a] > true_ages[a]
		lower_than_hpd += 1
	else
		raise "Unexpected relationship of true ages and hpd!"
	end
end
lower_than_hpd_proportion = lower_than_hpd/true_ages.size.to_f
inside_hpd_proportion = inside_hpd/true_ages.size.to_f
greater_than_hpd_proportion = greater_than_hpd/true_ages.size.to_f

# Write the overall proportion of ages below, inside, and above the HPD to the svg string.
lower_than_hpd_proportion_y = 70
svg_output << "  <text x=\"#{text_x}\" y=\"#{lower_than_hpd_proportion_y}\" font-family=\"#{font_family}\" font-size=\"#{font_size}\" fill=\"black\">\n"
svg_output << "    true age &#60; 95% HPD: #{(lower_than_hpd_proportion*100).round(1)}%\n"
svg_output << "  </text>\n"
inside_hpd_proportion_y = 90
svg_output << "  <text x=\"#{text_x}\" y=\"#{inside_hpd_proportion_y}\" font-family=\"#{font_family}\" font-size=\"#{font_size}\" fill=\"black\">\n"
svg_output << "    true age in 95% HPD: #{(inside_hpd_proportion*100).round(1)}%\n"
svg_output << "  </text>\n"
greater_than_hpd_proportion_y = 110
svg_output << "  <text x=\"#{text_x}\" y=\"#{greater_than_hpd_proportion_y}\" font-family=\"#{font_family}\" font-size=\"#{font_size}\" fill=\"black\">\n"
svg_output << "    true age &#62; 95% HPD: #{(greater_than_hpd_proportion*100).round(1)}%\n"
svg_output << "  </text>\n"
svg_output << "\n"

# Prepare the stats part of the SVG.
svg_output << "  <!--Stats-->\n"

# Calculate the proportion of true ages that is contained within the 95% HPD interval.
inside_hpd_young_nodes = 0
inside_hpd_old_nodes = 0
true_ages_young_nodes = 0
true_ages_old_nodes = 0
true_ages.size.times do |a|
	if true_ages[a] < 1
		true_ages_young_nodes += 1
	  if estimated_ages_uppers[a] >= true_ages[a] and estimated_ages_lowers[a] <= true_ages[a]
	    inside_hpd_young_nodes += 1
	  end
	else
		true_ages_old_nodes += 1
		if estimated_ages_uppers[a] >= true_ages[a] and estimated_ages_lowers[a] <= true_ages[a]
			inside_hpd_old_nodes += 1
		end
	end
end
inside_hpd_proportion_young_nodes = inside_hpd_young_nodes/true_ages_young_nodes.to_f
inside_hpd_proportion_old_nodes = inside_hpd_old_nodes/true_ages_old_nodes.to_f
stats_output << "Number of true ages of young nodes: #{true_ages_young_nodes}\n"
stats_output << "Number of true ages of old nodes: #{true_ages_old_nodes}\n"
stats_output << "Percentage within HPD interval of young nodes: #{'%.1f' % (inside_hpd_proportion_young_nodes*100)}\n"
stats_output << "Percentage within HPD interval of old nodes: #{'%.1f' % (inside_hpd_proportion_old_nodes*100)}\n"
stats_output << "Percentage within HPD interval of all nodes: #{'%.1f' % (inside_hpd_proportion*100)}\n"

# Calculate the mean HPD width for all true ages.
hpd_widths = []
hpd_widths_young_nodes = []
hpd_widths_old_nodes = []
true_ages.size.times do |a|
	hpd_widths << estimated_ages_uppers[a]-estimated_ages_lowers[a]
	if true_ages[a] < 1
		hpd_widths_young_nodes << estimated_ages_uppers[a]-estimated_ages_lowers[a]
	else
		hpd_widths_old_nodes << estimated_ages_uppers[a]-estimated_ages_lowers[a]
	end
end
mean_hpd_width = hpd_widths.mean
mean_hpd_width_young_nodes = hpd_widths_young_nodes.mean
mean_hpd_width_old_nodes = hpd_widths_old_nodes.mean
stats_output << "Mean HPD width of young nodes: #{'%.2f' % mean_hpd_width_young_nodes}\n"
stats_output << "Mean HPD width of old nodes: #{'%.2f' % mean_hpd_width_old_nodes}\n"
stats_output << "Mean HPD width of all nodes: #{'%.2f' % mean_hpd_width}\n"

# Write the mean HPD widths to the svg string.
mean_hpd_width_y = 50
svg_output << "  <text x=\"#{text_x}\" y=\"#{mean_hpd_width_y}\" font-family=\"#{font_family}\" font-size=\"#{font_size}\" fill=\"black\">\n"
svg_output << "    mean HPD width: #{mean_hpd_width.round(2)}\n"
svg_output << "  </text>\n"

# Finalize the SVG strings.
svg_output << "</svg>\n"

# Write the SVG string to file.
svg_out_file_name = ARGV[1]
svg_out_file = File.new(svg_out_file_name,"w")
svg_out_file.write(svg_output)
svg_out_file.close

# Write the stats string to file.
stats_out_file_name = ARGV[2]
stats_out_file = File.new(stats_out_file_name,"w")
stats_out_file.write(stats_output)
stats_out_file.close
