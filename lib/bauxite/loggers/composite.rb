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