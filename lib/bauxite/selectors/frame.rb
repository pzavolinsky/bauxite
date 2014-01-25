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
	# Change the selector scope to the given frame and finds an element in that
	# frame.
	#
	# This is a composite selector. The frame selector syntax is:
	#     frame=|frame_selector|child_selector
	#
	# Where +frame_selector+ is any selector available that matches the target
	# frame, +child_selector+ is any selector available that matches the target
	# element inside the target frame.
	#
	# Note that the '|' character can be replaced with any single-character
	# delimiter.
	#
	# Also note that frame selectors can be embedded to select a frame inside
	# a frame. To accompilish this, +child_selector+ can be a frame selector.
	#
	# For example:
	#     # assuming <iframe class="myframe">
	#     #            <div id="child">foo</div>
	#     #          </iframe>
	#     assert "frame=|css=.myframe|child" "foo"
	#     # => matches the 'child' element above.
	#
	# :category: Selector Methods
	def frame(arg, &block)
		delimiter = arg[0]
		items = arg[1..-1].split(delimiter, 2)
		frame = find(items[0])
		
		begin
			@ctx.driver.switch_to.frame frame
			find(items[1], &block)
		ensure
			@ctx.driver.switch_to.default_content
		end
	end
end
