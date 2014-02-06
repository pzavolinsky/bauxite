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

require 'pathname'

class Bauxite::Action
	# Captures a screenshot of the current browser window and saves it with
	# specified +file+ name. If +file+ is omitted a file name will be
	# generated based on the value of <tt>__TEST__</tt>, <tt>__FILE__</tt>
	# and <tt>__CAPTURE_SEQ__</tt>. If set, the value of <tt>__OUTPUT__</tt>
	# will be prefixed to +file+ (unless +file+ is an absolute path). The last
	# captured file name will be stored in <tt>__CAPTURE__</tt>.
	#
	# For example:
	#     capture
	#     # => this would capture the screenshot with a generated file name.
	#     
	#     capture my_file.png
	#     # => this would capture the screenshot to my_file.png in the current
	#     #    working directory.
	#
	# :category: Action Methods
	def capture(file = nil)
		unless file
			seq = @ctx.variables['__CAPTURE_SEQ__'] || 0
			test = @ctx.variables['__TEST__']
			@ctx.variables['__CAPTURE_SEQ__'] = seq + 1

			file = @ctx.variables['__FILE__'] || ''
			file = file[Dir.pwd.size+1..-1] if file.start_with? Dir.pwd
			
			file += "_#{seq}"
			file = "#{test}_#{file}" if test
			file = file.gsub(/[^A-Z0-9_-]/i, '_') + '.png'
		end

		unless Pathname.new(file).absolute?
			output = @ctx.variables['__OUTPUT__']
			if output
				Dir.mkdir output unless Dir.exists? output
				file = File.join(output, file)
			end
		end

		@ctx.driver.save_screenshot(file)

		@ctx.variables['__CAPTURE__'] = file
		true
	end
end
