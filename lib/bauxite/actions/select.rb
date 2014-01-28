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
	# Sets the value of the selected +HTMLSelect+ to +text+.
	#
	# +text+ can be the +value+ or the +text+ of the target +HTMLOption+.
	#
	# For example:
	#     # assuming <select id="s">
	#     #            <option value="one">First</option>
	#     #            <option value="two">Second</option>
	#     #          </select>
	#     select s Second
	#     select s two
	#     # => both actions select the second option.
	#
	# :category: Action Methods
	def select(selector, text)
		@ctx.find(selector) do |e|
			e = Selenium::WebDriver::Support::Select.new(e)
			begin
				e.select_by(:value, text)
			rescue Selenium::WebDriver::Error::NoSuchElementError
				e.select_by(:text, text)
			end
		end
	end
end
