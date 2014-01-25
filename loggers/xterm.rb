require_relative 'terminal'

# XTerm logger.
#
# This logger outputs colorized lines using xterm (VT100/2) escape
# sequences.
#
class Bauxite::Loggers::XtermLogger < Bauxite::Loggers::TerminalLogger

protected
	COLORS = { # :nodoc:
		:black        => '0;30',
		:dark_blue    => '0;34',
		:dark_green   => '0;32',
		:dark_cyan    => '0;36',
		:dark_red     => '0;31',
		:dark_purple  => '0;35',
		:dark_brown   => '0;33',
		:dark_gray    => '1;30',
		:gray         => '0;37',
		:blue         => '1;34',
		:green        => '1;32',
		:cyan         => '1;36',
		:red          => '1;31',
		:purple       => '1;35',
		:yellow       => '1;33',
		:white        => '1;37'
	}

	def _fmt(color, text, size = 0)
		text = super(color, text, size)
		if @options[:nc] or @options[:color] == 'no'
			text
		else
			"\033[#{COLORS[color]}m#{text}\033[0m"
		end
	end

	def _save_cursor
		print "\033[s"
		true
	end

	def _restore_cursor
		print "\033[u"
		true
	end
	
	def _screen_width
		begin
			require 'terminfo'
			TermInfo.screen_size[1]
		rescue Exception
			super
		end
	end
end