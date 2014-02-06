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

class Bauxite::Selector
	# Change the selector scope to the given window and finds an element in that
	# window.
	#
	# This is a composite selector. The window selector syntax is:
	#     window=|window_name|child_selector
	#
	# Where +window_name+ is the name or url pattern of the target window, 
	# +child_selector+ is any selector available that matches the target
	# element inside the target window.
	#
	# Note that the '|' character can be replaced with any single-character
	# delimiter.
	#
	# For example:
	#     # assuming <div id='label'>hello!</div> in popup.html
	#     js "window.w = window.open('popup.html', 'mypopup')"
	#     assert "window=|mypopup|label" "hello!"
	#     # => this assertion would pass
	#
	# :category: Selector Methods
	def window(arg, &block)
		delimiter = arg[0]
		name,child = arg[1..-1].split(delimiter, 2)
		current = @ctx.driver.window_handle
		begin
			window_name = name
			unless @ctx.driver.window_handles.include? name
				if name =~ /^\/.*\/[imxo]*$/
					name = eval(name)
				else
					name = /#{name}/
				end

				name = @ctx.driver.window_handles.find do |h|
					@ctx.driver.switch_to.window h
					@ctx.driver.current_url =~ name
				end
			end

			unless name
				raise Bauxite::Errors::AssertionError, "Cannot find a window matching '#{window_name}' (either by name exact match or by url regex)." 
			end

			@ctx.driver.switch_to.window name
			find(child, &block)
		ensure
			@ctx.driver.switch_to.window current
		end
	end
end
