#!/usr/bin/env ruby

require 'nokogiri'

#
# Parse HTML files generated with Selenium IDE and transform them into Bauxite.
#


ARGV.map do |path|
	open(path) do |file|
		[path, Nokogiri::HTML(open(file))]
	end
end.each do |path,page|
	puts path

	selenium_base = page.css('link[rel="selenium.base"]')[0]['href']

	File.open("#{path}.bxt", 'w+') do |bxt|
		page.css('tr').select { |tr| tr.css('td[colspan]').size == 0 }.each do |tr|
			
			data = tr.css('td').select { |td| td.text != '' }.map { |td| td.text }

			action = data[0]
			
			case action
			when 'open'
				url = data[1]
				url = url[1..-1] if url[0] == '/' and selenium_base[-1] == '/' # remove leading '/'
				data[1] = selenium_base + url
			when 'type'
				action = 'write'
			when 'verifyTextPresent'
				action = 'source'
			when 'clickAndWait'
				action = 'click'
			when 'waitForPageToLoad'
				action = 'wait'
				data[1] = (data[1].to_i / 1000).to_s
			when 'selectWindow'
				next
			end
			
			args = data[1..-1].map { |arg| '"'+arg.gsub('"', '""')+'"' }.join(' ')

			bxt.write "#{action} #{args}\n"
		end
	end
end