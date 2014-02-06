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
	# Asserts that the number of currently open windows equals +count+.
	#
	# For example:
	#     assertw
	#     # => this assertion would pass (only the main window is open)
	#     
	#     js "window.w = window.open()"
	#     assertw 2
	#     # => this assertion would pass (main window and popup)
	#
	#     js "setTimeout(function() { window.w.close(); }, 3000);"
	#     assertw 1
	#     # => this assertion would pass (popup was closed)
	#
	# :category: Action Methods
	def assertw(count = 1)
		@ctx.with_timeout Bauxite::Errors::AssertionError do
			unless @ctx.driver.window_handles.size == count.to_i
				raise Bauxite::Errors::AssertionError, "Assertion failed: all popups must be closed." 
			end
			true
		end
	end
end
