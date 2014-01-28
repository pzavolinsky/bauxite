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
	# Select an element by applying different Selector strategies.
	#
	# This selector tries to find elements by using the following strategies:
	# 1. default (id suffix)
	# 2. by +name+
	# 3. by +class_name+
	# 4. by +id+ fragment (the +id+ contains the text specified)
	# 5. by +placeholder+ attribute
	# 6. by text content (unless the element is a label)
	# 7. by referenced element (find a label by its text, then find the element
	#    pointed by the label's +for+ attribute)
	# 8  by child element (find a label by its text, then find the first
	#    element child control element, including input, select, textarea and
	#    button).
	#
	# For example:
	#     # assuming <label>By label parent<input type="text" value="By label parent"/></label>
	#     assert "smart=By label parent" "By label parent"
	#     # => the assertion succeeds.
	#
	# :category: Selector Methods
	def smart(arg, &block)
		b = lambda { |e| e }
		target   = _smart_try_find { default(arg, &b)                }
		target ||= _smart_try_find { selenium_find(:name, arg)       }
		target ||= _smart_try_find { selenium_find(:class_name, arg) }
		target ||= _smart_try_find { attr("id*:"+arg, &b)            }
		target ||= _smart_try_find { attr("placeholder:"+arg, &b)    }
		return yield target if target
		
		target = selenium_find(:xpath, "//*[contains(text(), '#{arg.gsub("'", "\\'")}')]")
		return yield target unless target.tag_name.downcase == 'label'
		label = target
		id = label['for']
		return yield selenium_find(:id, id) if id
		
		target = _smart_try_find { label.find_element(:css, "input, select, textarea, button") }
		return yield target if target
	end
	
private
	def _smart_try_find()
		wait = Selenium::WebDriver::Wait.new(:timeout => 0.01)
		wait.until { yield }
	rescue StandardError => e
		nil
	end
end
