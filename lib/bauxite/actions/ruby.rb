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

class Bauxite::Action
	# Load the specified ruby file into an isolated variable context and
	# execute the ruby code.
	#
	# +file+ can be a path relative to the current test file.
	#
	# An optional list of variables can be provided in +vars+. See #load.
	#
	# The ruby action file must contain a single lambda that takes a Context
	# instance as its only argument.
	#
	# For example:
	#     # === my_test.rb ======= #
	#     lambda do |ctx|
	#         ctx.exec_action 'echo "${message}"'
	#         ctx.driver.navigate.to 'http://www.ruby-lang.org'
	#         ctx.variables['new'] = 'from ruby!'
	#         ctx.exec_action 'return new'
	#     end
	#     # === end my_test.rb === #
	#
	#     # in main.bxt
	#     ruby my_test.rb "message=Hello World!"
	#     echo "${new}"
	#     # => this would print 'from ruby!'
	#
	# :category: Action Methods
	def ruby(file, *vars)
		# _load_file_action is defined in tryload.rb
		_load_file_action(file, *vars) do |f|
			content = ''
			File.open(f, 'r') { |ff| content = ff.read }
			eval(content).call(@ctx)
		end || (raise Bauxite::Errors::FileNotFoundError, "File not found: #{file}")
	end
end
