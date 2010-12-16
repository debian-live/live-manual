#! /usr/bin/env ruby

require 'nokogiri'

output_file=ARGV.shift
input_file=output_file+"~"

File.rename(output_file,input_file)
File.open(output_file,"w") do |o|
    doc=Nokogiri::HTML(open input_file)
    # CSS3 selectors don't support regexes, so this is a bit simplistic.
    # Change to use a custom pseudo class if anything more complex is needed.
    doc.css(%[table[summary~="segment"]]).remove
    o.puts doc.to_html
end
