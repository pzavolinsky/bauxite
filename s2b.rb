#!/usr/bin/env ruby

require 'optparse'
require 'nokogiri'

#
# Parse HTML files generated with Selenium IDE and transform them into Bauxite.
#
options = {
	:dir   => nil,
	:embed => false
}

cmd = File.basename(__FILE__)

OptionParser.new do |opts|
	opts.banner = "Usage: #{cmd} [options] [files...]"
	
	opts.separator ""
	opts.separator "Options: "
	opts.on("-d", "--directory DIR", "Output files into DIR")             { |v| options[:dir  ] = v }
	opts.on("-e", "--embed", "Do not extract the base url to a variable") { |v| options[:embed] = v }
	
	opts.separator ""
end.parse!

def parse_selector(selector)
	selector = 'xpath='+selector if selector[0..1] == '//'
	selector
end

ARGV.map do |path|
	open(path) do |file|
		[path, Nokogiri::HTML(open(file))]
	end
end.each do |path,page|
	puts path
	dir = options[:dir] || File.dirname(path)

	selenium_base = page.css('link[rel="selenium.base"]')[0]['href']
	base_ends_in_slash = (selenium_base[-1] == '/')

	unless options[:embed]
		env = File.join(dir, 'env')
		Dir.mkdir(env) unless Dir.exists? env

		File.open(File.join(env, 'test.bxt'), 'w+') do |f|
			f.write("set url \"#{selenium_base}\"\n")
			f.write("return *\n")
		end

		selenium_base = '${url}'
	end

	File.open("#{path}.bxt", 'w+') do |bxt|
		page.css('tr').select { |tr| tr.css('td[colspan]').size == 0 }.each do |tr|
			
			data = tr.css('td').select { |td| td.text != '' }.map { |td| td.text }

			action = data[0]
			args = data[1..-1]
			
			case action
			when 'open'
				url = args[0]
				url = url[1..-1] if url[0] == '/' and base_ends_in_slash # remove leading '/'
				args[0] = selenium_base + url
			when 'type'
				action = 'write'
				args[0] = parse_selector(args[0])
			when 'verifyTextPresent'
				action = 'source'
			when 'clickAndWait', 'click'
				action = 'click'
				args[0] = parse_selector(args[0])
			when 'waitForPageToLoad'
				action = 'wait'
				args[0] = (args[0].to_i / 1000).to_s
			when 'selectWindow'
				next
			end
			
			args = args.map { |arg| '"'+arg.gsub('"', '""')+'"' }.join(' ')

			bxt.write "#{action} #{args}\n"
		end
	end
end

unless options[:embed]
	puts '-----'
	puts 'Created env/test.bxt'
	puts 'Run tests with: bauxite.rb env/test.bxt <your test.bxt>'
end