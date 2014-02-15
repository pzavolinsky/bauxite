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
	# Load CSV files.
	#
	# :category: Parser Methods
	def csv(file)
		return nil unless file.downcase.end_with? '.csv'
		
		File.open(file) do |f|
			f.read.each_line.each_with_index.map do |text,line|
				text = text.sub(/\r?\n$/, '')
				next nil if text =~ /^\s*(#|$)/
				begin
					data = CSV.parse_line(text)
					[ data[0], data[1..-1].map { |a| a.strip }, nil, line ]
				rescue StandardError => e
					raise "#{file} (line #{line+1}): #{e.message}"
				end
			end
		end.select { |item| item != nil }
	end
end
