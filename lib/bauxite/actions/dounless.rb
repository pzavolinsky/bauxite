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
	# Executes +action+ only if +expected+ does not match +actual+.
	#
	# The conditional check in this action is similar to #assertv.
	#
	# For example:
	#     set first john
	#     set last doe
	#     dounless james ${first} assertv doe ${last}
	#     # => this assertion would pass.
	#     
	#     dounless false ${load_captcha} load captcha.bxt
	#     # => this would only load captcha.bxt if the load_captcha
	#     #    variable is not 'false'
	#
	# :category: Action Methods
	def dounless(expected, actual, action, *args)
		return false if actual =~ _pattern(expected)
		@ctx.exec_action_object(@ctx.get_action(action, args))
	end
end
