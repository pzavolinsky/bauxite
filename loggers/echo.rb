require 'terminfo'

module Loggers
	# Echo logger.
	#
	# This logger outputs the raw action text for every action executed.
	#
	# Note that this logger does not include execution status information
	# (i.e. action succeeded, failed or was skipped).
	#
	class EchoLogger < NullLogger
		
		# Echoes the raw action text.
		def log_cmd(action)
			puts action.text
			yield
		end
	end
end