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
	# Executes the specified +action+ expected to fail. If +action+ succeeds
	# the #failif action fails. If +action+ fails, #failif succeeds.
	#
	# #failif effectively negates the value of +action+. Note that this method
	# is intended to negate assertions (e.g. #assert, #assertv, #source, etc.).
	# The behavior when applied to other actions (e.g. #load, #ruby, #test,
	# etc.) is undefined.
	#
	# For example:
	#     # assuming <input type="text" id="hello" value="world" />
	#     assert hello world
	#     failif assert hello universe
	#     failif assertv true false
	#     # => these assertions would pass
	#
	# :category: Action Methods
	def failif(action, *args)
		@ctx.with_timeout Bauxite::Errors::AssertionError do
			begin
				@ctx.with_vars({ '__TIMEOUT__' => 0}) do
					@ctx.exec_parsed_action(action, args, false)
				end
			rescue Bauxite::Errors::AssertionError
				return true
			end
			raise Bauxite::Errors::AssertionError, "Assertion did not failed as expected:#{action} #{args.join(' ')}"
		end
	end
end
