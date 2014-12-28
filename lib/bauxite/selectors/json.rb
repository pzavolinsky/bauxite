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

require 'json'

class Bauxite::Selector
	# Select a field in a JSON document.
	#
	# The JSON selector syntax is:
	#     # For objects:
	#     json=key           # {"key":1}               => 1
	#     json=key.subkey    # {"key":{"subkey":2}}    => 2
	#     json=key[0]        # {"key": [3]}            => 3
	#     json=key[1].subkey # {"key": [{"subkey":4}]} => 4
	#     json=key.length    # {"key": [5]}            => 1
	#
	#     # For arrays:
	#     json=[0]           # [1]                     => 1
	#     json=[1].value     # [{"value": 2}]          => 2
	#     json=length        # [3]                     => 1
	#
	# For example:
	#     # assuming {"key": [{"subkey":4},{"val":"42"}]}
	#     assert json=key[0].subkey 4
	#     assert json=key[1].val 42
	#     assert json=key.length 2
	#     # => these assertions would pass
	#
	# :category: Selector Methods
	def json(arg, &block)
		source = JSON::parse(@ctx.driver.page_source.sub(/^<html[^>]*>.*<pre>/, '').sub(/<\/pre>.*<\/html>$/, ''))
		element = _json_find(source, arg)
		raise Selenium::WebDriver::Error::NoSuchElementError, "Cannot find JSON element: #{arg}" unless element

		element = element.to_s
		def element.text; self; end
		def element.tag_name; 'json'; end
		yield element if block_given?
		element
	end
	
private
	def _json_find(parent, selector)
		if selector[0] == '['
			delim = selector.index(']')
			raise ArgumentError, "Invalid format for JSON selector (missing closing ']'): #{selector}" unless delim
			i = selector[1...delim].to_i
			selector = selector[delim+1..-1]
			parent = parent[i]
			return parent if selector == ''
		end
		if selector[0] == '.'
			selector = selector[1..-1]
		end
		if selector == 'length' and parent.respond_to? :size
			return parent.size
		end

		delim = selector.index(/[\[.]/)
		if delim
			target = parent[selector[0...delim]]
			return unless target
			rest = selector[delim..-1]
			_json_find(target, rest)
		else
			parent[selector]
		end
	end
end
