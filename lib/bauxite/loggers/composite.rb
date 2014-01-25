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

# Composite logger.
#
# This composite logger forwards logging calls to each of its children.
#
# Set the +:loggers+ option to a comma-separated list of logger names
#
class Bauxite::Loggers::CompositeLogger
	
	# Constructs a new composite logger instance.
	def initialize(options)
		@loggers = options[:loggers].split(',').map do |l|
			Bauxite::Context::load_logger(l, options)
		end
	end
	
	# Pretty prints action information and status.
	#
	# This implementation only yileds in the first logger.
	# 
	# Additional loggers are called after the block completed.
	#
	def log_cmd(action, &block)
		ret = @loggers[0].log_cmd(action, &block)
		@loggers[1..-1].each { |l| l.log_cmd(action) { ret } }
		ret
	end

	# Returns a colorized debug prompt.
	#
	# This implementation returns the debug_prompt of the first logger.
	#
	def debug_prompt
		@loggers[0].debug_prompt
	end
	
	# Updates action progress.
	def progress(value)
		@loggers.each { |l| l.progress(value) }
	end
	
	# Prints the specified string.
	#
	# See Bauxite::Loggers::NullLogger#print
	#
	def log(s, type = :info)
		@loggers.each { |l| l.log(s, type) }
	end
end