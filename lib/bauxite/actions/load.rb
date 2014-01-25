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
	# Load the specified file into an isolated variable context and execute
	# the actions specified. If the file does not exist, this action fails.
	# See #tryload for a similar action that skips if the file does not exist.
	#
	# +file+ can be a path relative to the current test file.
	#
	# An optional list of variables can be provided in +vars+. These variables
	# will override the value of the context variables for the execution of the
	# file (See Context#with_vars).
	#
	# The syntax of the variable specification is:
	#     "var1_name=var1_value" "var2_name=var2_value" ...
	#
	# For example:
	#     load other_test.bxt "othervar=value_just_for_other"
	#     echo "${othervar}"
	#     # => this would load and execute other_test.bxt, injecting othervar
	#     #    into its context. After other_test.bxt completes, othervar will
	#     #    be restored to its original value (or be undefined if it didn't
	#     #    exist prior to the 'load' call).
	#
	# :category: Action Methods
	def load(file, *vars)
		tryload(file, *vars) || (raise Bauxite::Errors::FileNotFoundError, "File not found: #{file}")
	end
end
