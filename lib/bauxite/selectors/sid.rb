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
	# Select an element by id suffix.
	#
	# This is the default selector. Any selector strings that do not contain an
	# equal sign (i.e. '=') will use this selector.
	#
	# For example:
	#     # assuming <div id="strange_uuid_like_stuff_myDiv">foo</div>
	#     assert sid=myDiv "foo"
	#     # => matches the element above.
	#
	# :category: Selector Methods
	def sid(arg, &block)
		selenium_find(:css, "[id$='#{arg.gsub("'", "\\'")}']", &block)
	end
end
