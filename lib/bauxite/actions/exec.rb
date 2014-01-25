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
	# Executes +command+, optionally storing the results in a variable.
	#
	# If the first argument of +command+ is <tt>name=...</tt> the results
	# of the execution will be assigned to the variable named +name+.
	#
	# For example:
	#     exec "that_day=date --date='2001-01-01' | cut -f 1 -d ' '"
	#     echo "${that_day}"
	#     # => this would print 'Mon'
	#
	# :category: Action Methods
	def exec(*command)
		data = command[0].split('=', 2)
		name = nil
		if (data.size == 2)
			name = data[0]
			command[0] = data[1]
		end

		ret = `#{command.join(' ')}`
		@ctx.variables[name] = ret.strip if name
	end
end
