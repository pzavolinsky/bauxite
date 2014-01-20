require 'terminfo'

# XTerm logger.
#
# This logger outputs colorized lines using xterm (VT100/2) escape
# sequences.
#
class RUITest::Loggers::XtermLogger < RUITest::Loggers::NullLogger
	
	# Constructs a new XTerm logger instance.
	def initialize
		@max_cmd_size = RUITest::Context::max_action_name_size
	end
	
	# Pretty prints action information and status.
	def log_cmd(action)
		width = TermInfo.screen_size[1]
		cmd = action.cmd.downcase.ljust(@max_cmd_size)
		max_args_size = width-cmd.size-1-6-1-1

		print "#{_fmt(:light_blue, cmd)} "
		s = action.args(true).join(' ')
		s = s[0...max_args_size-3]+'...' if s.size > max_args_size
		print s.ljust(max_args_size)
		_save_cursor
		color = :light_green
		text  = 'OK'
		ret = yield
		if not ret
			color = :yellow
			text  = 'SKIP'
		end
		_restore_cursor
		puts " #{block(color, text, 5)}"
		ret
	rescue
		_restore_cursor
		puts " #{block(:light_red, 'ERROR', 5)}"
		raise
	end

	# Returns a colorized debug prompt.
	def debug_prompt
		_fmt(:white, 'debug> ')
	end
	
	# Updates action progress.
	def progress(value)
		_restore_cursor
		print " #{block(:light_gray, value.to_s, 5)}"
	end
	
private
	COLORS = { # :nodoc:
		:black        => '0;30',
		:blue         => '0;34',
		:green        => '0;32',
		:cyan         => '0;36',
		:red          => '0;31',
		:purple       => '0;35',
		:brown        => '0;33',
		:light_gray   => '0;37',
		:black        => '0;30',
		:dark_gray    => '1;30',
		:light_blue   => '1;34',
		:light_green  => '1;32',
		:light_cyan   => '1;36',
		:light_red    => '1;31',
		:light_purple => '1;35',
		:yellow       => '1;33',
		:white        => '1;37'
	}

	def _fmt(color, text, size = 0)
		"\033[1;#{COLORS[color]}m#{text.center(size)}\033[0m"
	end

	def _save_cursor
		print "\033[s"
	end

	def _restore_cursor
		print "\033[u"
	end

	def block(color, text, size)
		"#{_fmt(:white, '[')}#{_fmt(color, text, size)}#{_fmt(:white, ']')}"
	end
end