# Test logger class.
#
# Test loggers handle test output format.
#
# The default logger does not provide any output logging.
#
# This default behavior can be overriden in a custom logger passed to the
# Context constructor. By convention, custom loggers are defined in the 
# 'loggers/' directory. Custom loggers replace the #log_cmd and/or the
# #debug_prompt methods.
#
class Logger
	# Executes the given block in a logging context.
	#
	# The default implementation does not provide any logging capabilities.
	#
	# For example:
	#     log.log_cmd('echo', 'Hello World!') do
	#         puts 'Hello World!'
	#     end
	#     # => echoes 'Hello World!'
	#
	def log_cmd(cmd, args)
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
end
