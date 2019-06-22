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

# Define a class for lines of the SVG graph.
class Line
	def initialize(x_start,x_end,y_start,y_end,color,stroke,opacity)
		@x_start = x_start
		@x_end = x_end
		@y_start = y_start
		@y_end = y_end
		@color = color
		@stroke = stroke
		@opacity = opacity
	end
	def to_svg
		svg = "<line x1=\"#{@x_start.round(3)}\" y1=\"#{@y_start.round(3)}\" x2=\"#{@x_end.round(3)}\" y2=\"#{@y_end.round(3)}\" stroke=\"#{@color}\" stroke-width=\"#{@stroke}\" stroke-opacity=\"#{@opacity}\" />"
		svg
	end
end

# Define class for circles of the SVG graph.
class Circle
	def initialize(x,y,radius,fill_color,stroke_color,stroke_width,opacity)
		@x = x
		@y = y
		@radius = radius
		@fill_color = fill_color
		@stroke_color = stroke_color
		@stroke_width = stroke_width
		@fill_opacity = opacity
		@stroke_opacity = opacity
	end
	def to_svg
		svg = "<circle cx=\"#{@x}\" cy=\"#{@y}\" r=\"#{@radius}\" fill=\"#{@fill_color}\" stroke=\"#{@stroke_color}\" stroke-width=\"#{@stroke_width}\" fill-opacity=\"#{@fill_opacity}\" stroke-opacity=\"#{@stroke_opacity}\" />"
		svg
	end
end

# Define class for paths of the SVG graph.
class Path
	def initialize(x,y,fill,color,stroke,opacity)
		@x = [x]
		@y = [y]
		@fill = fill
		@color = color
		@stroke = stroke
		@opacity = opacity
	end
	def add_point(x,y)
		@x << x
		@y << y
	end
	def to_svg
		svg = "<path d=\"M #{@x[0]} #{@y[0]} "
		if @x.size > 1
			1.upto(@x.size-1) do |z|
				svg << "L #{@x[z]} #{@y[z]} "
			end
		end
		svg << "\" fill=\"#{@fill}\" stroke=\"#{@color}\" stroke-width=\"#{@stroke}\" fill-opacity=\"#{@opacity}\" />"
		svg
	end
end

# Get the command line arguments.
input_file_name = ARGV[0]
svg_out_file_name = ARGV[1]

# Read the input files.
input_file = File.open(input_file_name)
input_lines = input_file.readlines

# Get the true ages and the corresponding proportional age errors.
true_ages = []
estimated_ages = []
log_prop_ages = []
prop_age_errors = []
log_prop_ages = []
input_lines.each do |l|
	unless l.strip == ""
		unless l.include?("true")
			line_ary = l.split
			true_age = line_ary[0].to_f
			estimated_age = line_ary[1].to_f
			true_ages << true_age
			estimated_ages << estimated_age
			prop_age_errors << (estimated_age-true_age).abs/true_age
			log_prop_ages << Math.log2(estimated_age/true_age)
		end
	end
end

# Some specifications for the SVG output.
dimX = 473.684210526/3.5277777778
dimY = 450/3.5277777778
line_width = 2
frame_stroke_width = 2
color = "#ed2224"
line_alpha = 1.0
line_width = 3.0
min_error = -1
max_error = 2
max_age = 5

# Prepare the header of the SVG string.
svg_output = ""
svg_output << "<?xml version=\"1.0\" standalone=\"no\"?>\n"
svg_output << "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\" \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">\n"
svg_output << "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"#{dimX}\" height=\"#{dimY}\" viewBox=\"0 0 #{dimX} #{dimY}\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n"
svg_output << "\n"

# Write the frame.
svg_output << "  <!--Frame-->\n"
svg_output << "  <rect style=\"stroke:black; stroke-width:#{frame_stroke_width/2.0}px; fill:none\" x=\"0\" y=\"0\" width=\"#{dimX}\" height=\"#{dimY}\" />\n"
svg_output << "\n"

# Add a circle to the SVG for each proportional node age error.
lines = []
circles = []
true_ages.size.times do |x|
	if true_ages[x] < max_age
		x_pos = (true_ages[x]/max_age)*dimX
		y_pos = ((max_error-log_prop_ages[x])/(max_error-min_error))*dimY
		circles << Circle.new(x_pos,y_pos,1.1336797355,color,"none",1.0,0.2)
	end
end

# Create a path for the line connecting means in bins.
bin_width = 0.2
path = nil
(max_age/bin_width).to_i.times do |x|
	bin_center = (x*bin_width)+(bin_width/2.0)
	bin_values = []
	true_ages.size.times do |x|
		if (true_ages[x]-bin_center).abs < (bin_width/2.0)
			bin_values << log_prop_ages[x]
		end
	end
	bin_mean = bin_values.mean
	x_pos = (bin_center/max_age)*dimX
	y_pos = ((max_error-bin_mean)/(max_error-min_error))*dimY
	if x == 0
		path = Path.new(x_pos,y_pos,"none",color,1.5,1.0)
	else
		path.add_point(x_pos,y_pos)
	end
end

# Add lines to svg.
lines.each {|l| svg_output << "    #{l.to_svg}\n"}

# Add circles to svg.
circles.each {|c| svg_output << "    #{c.to_svg}\n"}

# Add paths to svg.
svg_output << "    #{path.to_svg}\n"

# Finalize the SVG string
svg_output << "</svg>\n"

# Write the SVG string to file.
svg_out_file = File.new(svg_out_file_name,"w")
svg_out_file.write(svg_output)
svg_out_file.close

# Calculate and report statistics.
prop_age_errors_young_nodes = []
prop_age_errors_old_nodes = []
prop_age_errors_all_nodes = []
prop_age_errors.size.times do |x|
	if true_ages[x] > 1
		prop_age_errors_old_nodes << prop_age_errors[x]
		prop_age_errors_all_nodes << prop_age_errors[x]
	elsif true_ages[x] > 0.1
		prop_age_errors_young_nodes << prop_age_errors[x]
		prop_age_errors_all_nodes << prop_age_errors[x]
	end
end

puts "Proportional error in #{input_file_name}:"
puts "Young nodes: #{'%.1f' % (prop_age_errors_young_nodes.mean*100)}"
puts "Old nodes: #{'%.1f' % (prop_age_errors_old_nodes.mean*100)}"
puts "Overall: #{'%.1f' % (prop_age_errors_all_nodes.mean*100)}"
puts
puts
