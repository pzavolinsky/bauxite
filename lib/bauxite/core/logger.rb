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
	# Test loggers module
	# 
	# The default Logger class and all custom loggers must be included in this
	# module.
	#
	module Loggers
		# Test logger class.
		#
		# Test loggers handle test output format.
		#
		# The default logger does not provide any output logging.
		#
		# This default behavior can be overriden in a custom logger passed to the
		# Context constructor (see Context::new). By convention, custom loggers are
		# defined in the 'loggers/' directory.
		#
		class NullLogger
			
			# Constructs a new null logger instance.
			#
			def initialize(options)
				@options = options
			end
			
			# Executes the given block in a logging context.
			#
			# This default implementation does not provide any logging 
			# capabilities.
			#
			# For example:
			#     log.log_cmd('echo', 'Hello World!') do
			#         puts 'Hello World!'
			#     end
			#     # => echoes 'Hello World!'
			#
			def log_cmd(action)
				yield
			end
			
			# Returns the prompt shown by the debug console (see Context#debug).
			# 
			# For example:
			#     log.debug_prompt
			#     # => returns the debug prompt
			def debug_prompt
				'debug> '
			end
			
			# Updates the progress of the current action.
			def progress(value)
			end

			# Logs the specified string.
			#
			# +type+, if specified, should be one of +:error+, +:warning+,
			# +:info+ (default), +:debug+.
			#
			def log(s, type = :info)
				print s
			end
			
			# Completes the log execution.
			#
			def finalize(ctx)
			end
		end
		
		# Report logger.
		#
		# This base logger class can be inherited to create reporting loggers.
		#
		# Descendent classes must override the #finalize method and iterate the
		# <tt>@data</tt> array to produce the report.
		#
		# The items included in the <tt>@data</tt> array contain the
		# following fields:
		# [:name]
		#   Name of the current test.
		# [:actions]
		#   Array of actions with the following fields
		#   - +:cmd+: name of the action.
		#   - +:args+: action arguments.
		#   - +:action+: action object.
		#   - +:status+: action execution status: +:ok+, +:skip+ or +:error+.
		#   - +:capture+: path to the current capture, if any.
		#
		# For an example of a ReportLogger implementation see the HtmlLogger
		# class.
		#
		class ReportLogger < NullLogger
			# Constructs a new report logger instance.
			#
			def initialize(options)
				super(options)
				@data = []
			end
			
			# Logs the specified string.
			#
			# +type+, if specified, should be one of +:error+, +:warning+,
			# +:info+ (default), +:debug+.
			#
			def log(s, type = :info)
			end
					
			# Echoes the raw action text.
			def log_cmd(action)
				stime = Time.new
				ret = yield || false
				etime = Time.new
			ensure
				etime ||= Time.new
				status = case ret; when nil; :error; when false; :skip; else :ok; end
				
				test_name = action.ctx.variables['__TEST__'] || 'Main'
				test = @data.find { |t| t[:name] == test_name }
				unless test
					test = { :name => test_name, :actions => [] }
					@data << test
				end
				
				capture = action.ctx.variables['__CAPTURE__']
				if capture == @last_capture
					capture = nil
				else
					@last_capture = capture
				end
				
				test[:actions] << {
					:cmd     => action.cmd,
					:args    => action.args(true),
					:action  => action,
					:status  => status,
					:time    => (etime - stime),
					:capture => capture
				}
				
				ret
			end
			
			# Completes the log execution.
			#
			def finalize(ctx)
			end
		end
	end
end