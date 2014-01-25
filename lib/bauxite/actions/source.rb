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
	# Asserts that the page source matches +text+.
	#
	# +text+ can be a regular expression. See #assert for more details.
	#
	# For example:
	#     # assuming <html><body>Hello World!</body></html>
	#     source "Hello.*!"
	#     # => this assertion would pass
	#
	# :category: Action Methods
	def source(text)
		@ctx.with_timeout Bauxite::Errors::AssertionError do
			actual = @ctx.driver.page_source
			verbose = @ctx.options[:verbose] ? "\nPage source:\n#{actual}" : ''
			unless actual =~ _pattern(text)
				raise Bauxite::Errors::AssertionError, "Assertion failed: page source does not match '#{text}'#{verbose}"
			end
			true
		end
	end
end
