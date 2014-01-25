# Terminal logger.
#
# This logger outputs text using basic text formatting for a terminal
# window.
#
class Bauxite::Loggers::TerminalLogger < Bauxite::Loggers::NullLogger
	# Constructs a new Terminal logger instance.
	def initialize(options)
		super(options)
		@max_cmd_size = Bauxite::Context::max_action_name_size
	end
	
	# Pretty prints action information and status.
	def log_cmd(action)
		width = _screen_width
		cmd = action.cmd.downcase
		color = _cmd_color(cmd)
		cmd = cmd.ljust(@max_cmd_size)
		max_args_size = width-cmd.size-1-6-1-1

		print "#{_fmt(color, cmd)} "
		s = action.args(true).join(' ')
		s = s[0...max_args_size-3]+'...' if s.size > max_args_size
		print s.ljust(max_args_size)
		_save_cursor
		color = :green
		text  = 'OK'
		ret = yield
		if not ret
			color = :yellow
			text  = 'SKIP'
		end
		_restore_cursor
		puts " #{_block(color, text, 5)}"
		ret
	rescue
		_restore_cursor
		puts " #{_block(:red, 'ERROR', 5)}"
		raise
	end

	# Returns a colorized debug prompt.
	def debug_prompt
		_fmt(:white, super)
	end
	
	# Updates action progress.
	def progress(value)
		if _restore_cursor
			print " #{_block(:gray, value.to_s, 5)}"
		end
	end
	
	# Prints the specified string.
	#
	# See Bauxite::Loggers::NullLogger#print
	#
	def log(s, type = :info)
		color = :gray
		case type
		when :error
			color = :red
		when :warning
			color = :yellow
		when :debug
			color = :purple
		end
		super _fmt(color, s), type
	end

protected
	# Centers +text+ to a fixed size with.
	def _fmt(color, text, size = 0)
		text.center(size)
	end
	
	# Save the current cursor position,
	def _save_cursor
		false
	end
	
	# Restores the cursor to the previously saved cursor position.
	def _restore_cursor
		false
	end

	# Prints +text+ centered inside a square-bracketed block.
	def _block(color, text, size)
		"#{_fmt(:white, '[')}#{_fmt(color, text, size)}#{_fmt(:white, ']')}"
	end

	# Get the color of +cmd+.
	def _cmd_color(cmd)
		case cmd
		when 'load'
			return :cyan
		when 'test'
			return :purple
		else
			return :blue
		end
	end
	
	# Returns the terminal screen width.
	def _screen_width
		80
	end
end