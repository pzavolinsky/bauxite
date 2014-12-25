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

# File logger.
#
# This logger outputs the raw action text for every action executed to
# the file specified in the +file+ logger option.
#
# File logger options include:
# [<tt>file</tt>] Output file name.
# [<tt>verbose</tt>] Output all log (e.g. errors) to the file.
#
#
class Bauxite::Loggers::FileLogger < Bauxite::Loggers::NullLogger
	
	# Constructs a new echo logger instance.
	def initialize(options)
		super(options)
		@file = options[:file]
		unless @file and @file != ''
			raise ArgumentError, "FileLogger configuration error: Undefined 'file' option."
		end
		@verbose = options[:verbose]
		@lines = []
	end
	
	# Completes the log execution.
	def finalize(ctx)
		File.open(ctx.output_path(@file), 'w') { |f| f.write(@lines.join("\n")) }
	end
	
	# Echoes the raw action text.
	def log_cmd(action)
		@lines << action.text
		yield
	end

	# Logs the specified string.
	#
	# +type+, if specified, should be one of +:error+, +:warning+,
	# +:info+ (default), +:debug+.
	#
	def log(s, type = :info)
		if @verbose
			@lines << s
		else
			super
		end
	end
end