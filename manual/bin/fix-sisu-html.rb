#! /usr/bin/env ruby

require 'nokogiri'

output_file=ARGV.shift
input_file=output_file+"~"

File.rename(output_file,input_file)
File.open(output_file,"w") do |o|
    doc=Nokogiri::HTML(open input_file)
    # CSS3 selectors don't support regexes, so we take a shotgun approach,
    # removing all tables with summaries (OK for current sisu output).
    # Change to use a custom pseudo class if anything more refined is needed.
    doc.css(%[table[summary]]).remove
    toc=doc.css(%[h2,h4[class$="toc"]]).each do |node|
	node.remove if node.inner_text.match(/Metadata|Manifest|SiSU/)
    end
    o.puts doc.to_html
end
