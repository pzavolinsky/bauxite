#--
# Copyright (c) 2014 Patricio Zavolinsky
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

class Bauxite::Parser
	# Load Selenium IDE HTML files.
	#
	# :category: Parser Methods
	def selenium_ide_html(file)
		return nil unless file.downcase.end_with? '.html'
		
		File.open(file) do |f|
			content = f.read
			
			data = content.gsub(/[\n\r]/, '')
			selenium_base = data.sub(/.*rel="selenium.base" href="([^"]*)".*/, '\1')
			base_ends_in_slash = (selenium_base[-1] == '/')
			
			data
			.gsub('<tr>', "\naction=")
			.gsub('</tr>', "\n")
			.each_line.grep(/^action=/)
			.map { |line| line.match(/^action=\s*<td>([^<]*)<\/td>\s*<td>([^<]*)<\/td>\s*<td>([^<]*)<\/td>.*$/) }
			.select { |match| match }
			.map { |match| match.captures }
			.map do |action|
				case action[0].downcase
				when 'open'
					url = action[1]
					url = url[1..-1] if url[0] == '/' and base_ends_in_slash # remove leading '/'
					action[1] = selenium_base + url
				when 'type'
					action[0] = 'write'
					action[1] = _selenium_ide_html_parse_selector(action[1])
				when 'verifytextpresent'
					action[0] = 'source'
				when 'clickandwait', 'click'
					action[0] = 'click'
					action[1] = _selenium_ide_html_parse_selector(action[1])
				when 'waitforpagetoload'
					action[0] = 'wait'
					action[1] = (action[1].to_i / 1000).to_s
				when 'assertvalue'
					action[0] = 'assert'
					action[1] = _selenium_ide_html_parse_selector(action[1])
				when 'waitforpopup'
					action = [] # remove
				end
				action = action.select { |a| a != '' }
				[ action[0], action[1..-1], nil, 0 ]
			end
			.select { |a| a[0] }
		end
	end

private
	def _selenium_ide_html_parse_selector(selector)
		selector = 'xpath='+selector if selector[0..1] == '//'
		selector
	end
end
