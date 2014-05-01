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
	# Load +file+ using the #load action into a new test context.
	#
	# If +name+ is specified, it will be used as the test name.
	#
	# An optional list of variables can be provided in +vars+. These variables
	# will override the value of the context variables for the execution of the
	# file (See Context#with_vars).
	#
	# If any action in the test context fails, the whole test context fails,
	# and the execution continues with the next test context (if any).
	#
	# For example:
	#     test mytest.bxt "My Test" my_var=1
	#     # => this would load mytest.bxt into a new test context
	#     #    named "My Test", and within that context ${my_var}
	#     #    would expand to 1.
	#
	# :category: Action Methods
	def test(file, name = nil, *vars)
		delayed = load(file, *vars)
		name = name || file
		lambda do
			begin
				t = Time.new
				status = 'ERROR'
				error = nil
				@ctx.with_vars({ '__TEST__' => name }) do
					delayed.call
					status = 'OK'
				end
			rescue StandardError => e
				@ctx.print_error(e)
				error = e
			ensure
				@ctx.tests << {
					:name => name,
					:status => status,
					:time => Time.new - t,
					:error => error
				}
			end
		end
	end
end
