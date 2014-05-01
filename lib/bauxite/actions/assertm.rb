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
	# Asserts that a native modal popup is present (e.g. alert, confirm,
	# prompt, etc.) and that its text matches the specified +text+.
	#
	# +text+ can be a regular expression. See #assert for more details.
	#
	# The second +action+ parameter specifies the action to be performed
	# on the native popup. The default action is to +accept+ the popup.
	# Alternatively, the action specified could be to +dismiss+ the popup.
	#
	# For example:
	#     # assuming the page opened an alert popup with the "hello world!"
	#     # text
	#     assertm "hello world!"
	#     # => this assertion would pass
	#
	# :category: Action Methods
	def assertm(text, action = 'accept')
		a = @ctx.driver.switch_to.alert
		unless a.text =~ _pattern(text)
			raise Bauxite::Errors::AssertionError, "Assertion failed: expected '#{a.text}', got '#{actual}'"
		end
		a.send(action.to_sym)
	end
end
