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
	# Asserts that the value of the selected element matches +text+.
	#
	# +text+ is a regular expression. +text+ can be surrounded by +/+ 
	# characters followed by regular expression flags.
	#
	# For example:
	#     # assuming <input type="text" id="hello" value="world" />
	#     assert hello world
	#     assert hello wor
	#     assert hello ^wor
	#     assert hello /WorlD/i
	#     # => these assertions would pass
	#
	# :category: Action Methods
	def assert(selector, text)
		@ctx.with_timeout Bauxite::Errors::AssertionError do
			@ctx.find(selector) do |e|
				actual = @ctx.get_value(e)
				unless actual =~ _pattern(text)
					raise Bauxite::Errors::AssertionError, "Assertion failed: expected '#{text}', got '#{actual}'"
				end
				true
			end
		end
	end
end
