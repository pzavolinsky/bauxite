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
require 'net/http'

class Bauxite::Action
	# Replays the current GET request and asserts that the HTTP headers
	# returned by that request match each of the +args+ specified.
	#
	# Note that this action results in an additional HTTP GET request to
	# the current browser url.
	#
	# The syntax of +args+ is:
	#     "header_name1=expression1" "header_name2=expression2" ...
	#
	# Where +expression+ is a regular expression. Note that multiple
	# headers can be asserted in a single #asserth call. Also note that
	# if the same header is specified more than once, the value of the
	# header must match every expression specified.
	#
	# For example:
	#     # assuming response headers { 'Content-Type' => 'text/plain' }
	#     asserth "content-type=plain"
	#     asserth "content-type=^text" "content-type=/plain$"
	#     # => these assertions would pass
	#
	# :category: Action Methods
	def asserth(*args)
		uri = URI(@ctx.driver.current_url)
		res = Net::HTTP.get_response(uri)
		args.each do |a|
			name,value = a.split('=', 2);
			name = name.strip.downcase
			value = value.strip

			actual = res[name] || ''
			unless actual =~ _pattern(value)
				raise Bauxite::Errors::AssertionError, "Assertion failed for HTTP Header '#{name}': expected '#{value}', got '#{actual}'"
			end
		end
	end
end
