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
	# Returns the specified variables to the parent scope (if any).
	#
	# If +vars+ is <tt>*</tt> every variable defined in the current scope
	# will be returned to the parent scope.
	#
	# The syntax of the variable specification is:
	#     "var1_name" "var2_name" ...
	#
	# Note that this method provides an action named +return+ and not
	# return_action.
	#
	# For example:
	#     set result "42"
	#     return result
	#     # => this would inject the result variable (whose value is 42)
	#     #    into the calling context.
	#
	# Full example (see #load, #write, #click, #store and #assert for more
	# details):
	#     # in main.bxt
	#     load login.txt "username=jdoe" "password=hello world!"
	#
	#         # in login.bxt
	#         write id=user "${username}"
	#         write id=pass "${password}"
	#         click id=login
	#         store id=loginName fullName
	#         return fullName
	#
	#     # back in main.bxt
	#     assert id=greeting "Welcome ${fullName}!"
	#     # => this assertion uses the variable returned from login.bxt
	#
	# :category: Action Methods
	def return_action(*vars)
		rets = @ctx.variables['__RETURN__'] || []
		@ctx.variables['__RETURN__'] = rets + vars
	end
end
