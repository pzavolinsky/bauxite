# File logger.
#
# This logger outputs the raw action text for every action executed to
# the file specified in the +file+ logger option.
#
class Bauxite::Loggers::FileLogger < Bauxite::Loggers::NullLogger
	
	# Constructs a new echo logger instance.
	def initialize(options)
		super(options)
		@file = options[:file]
		unless @file and @file != ''
			raise ArgumentError, "FileLogger configuration error: Undefined 'file' option."
		end
		File.open(@file, "w") {} # truncate file
	end
	
	# Echoes the raw action text.
	def log_cmd(action)
		File.open(@file, 'a+') { |f| f.write(action.text+"\n") }
		yield
	end
end