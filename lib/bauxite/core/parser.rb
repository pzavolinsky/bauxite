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

module Bauxite
	# Parser common state and behavior.
	module ParserModule
		# Constructs a new test parser instance.
		def initialize(ctx)
			@ctx = ctx
		end
		
		# Parse +file+ and yield the resulting actions.
		def parse(file)
			actions = nil
			Context::parsers.any? { |p| actions = send(p, file) }
			
			unless actions
				raise Errors::FormatError, "Invalid format in '#{file}'. None of the available parsers can understand this file format."
			end
			
			actions.each do |action, args, text, line|
				yield action.strip.downcase, args, text, file, line
			end
		end
	end
		
	# Parser class.
	#
	# Parser represent different strategies for reading input files into lists
	# of Bauxite actions.
	#
	# Each custom parser is defined in a separate file in the 'parsers/'
	# directory. These files should avoid adding public methods other than
	# the parser method itself. Also, no +attr_accessors+ should be added.
	#
	# Parser methods can use the +ctx+ attribute to refer to the current test
	# Context.
	# Parser methods receive a single action hash argument including <tt>:file</tt>
	# and return an array of hashes or nil if the parser can't handle the file.
	#
	# For example:
	#     # === parsers/my_parser.rb ======= #
	#     class Parser
	#         # :category: Parser Methods
	#         def my_parser(action)
	#             # open and read file
	#             [
	#                 { :cmd => 'echo', :args => [ 'hello world'                 ] },
	#                 { :cmd => 'write',:args => [ 'id=username', 'jdoe'         ] },
	#                 { :cmd => 'write',:args => [ 'id=password', 'hello world!' ] }
	#             ]
	#         end
	#     end
	#     # === end parsers/my_parser.rb === #
	#
	class Parser
		include ParserModule
	end
end