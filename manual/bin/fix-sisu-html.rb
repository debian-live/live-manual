#! /usr/bin/env ruby

require 'nokogiri'

output_file=ARGV.shift
input_file=output_file+"~"
debug=ARGV.shift.to_i

File.rename(output_file,input_file)
doc=Nokogiri::HTML(open input_file)

# Rewrite the input file so that comparison with the output will only
# show changes introduced by the filter, since Nokogiri parsed output
# introduces numerous subtle differences even without filtering.
File.open(input_file,"w") {|o| o.puts doc.to_html} if debug > 0

File.open(output_file,"w") do |o|
	# CSS3 selectors don't support regexes, so we take a shotgun approach,
	# removing all tables with summaries (OK for current sisu output).
	# Change to use a custom pseudo class if anything more refined is needed.
	doc.css(%[table[summary]]).remove
	toc=doc.css(%[h2,h4[class$="toc"]]).each do |node|
		node.remove if node.inner_text.match(/Metadata|Manifest|SiSU/)
	end
	o.puts doc.to_html
end

File.delete(input_file) unless debug > 0
