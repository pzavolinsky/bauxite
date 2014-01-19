require 'terminfo'

module Loggers
	class BashLogger
		COLORS = {
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

		def fmt(color, text, size = 0)
			"\033[1;#{COLORS[color]}m#{text.center(size)}\033[0m"
		end

		def progress(value)
			restore_cursor
			print " #{block(:light_gray, value.to_s, 5)}"
		end

		def save_cursor
			print "\033[s"
		end

		def restore_cursor
			print "\033[u"
		end

		def block(color, text, size)
			"#{fmt(:white, '[')}#{fmt(color, text, size)}#{fmt(:white, ']')}"
		end

		def log_cmd(cmd, args)
			width = TermInfo.screen_size[1]
			cmd = cmd.downcase.ljust(7)
			max_args_size = width-cmd.size-1-6-1-1

			print "#{fmt(:light_blue, cmd)} "
			s = args.join(' ')
			s = s[0...max_args_size-3]+'...' if s.size > max_args_size
			print s.ljust(max_args_size)
			save_cursor
			color = :light_green
			text  = 'OK'
			ret = yield
			if not ret
				color = :yellow
				text  = 'SKIP'
			end
			restore_cursor
			puts " #{block(color, text, 5)}"
			ret
		rescue
			restore_cursor
			puts " #{block(:light_red, 'ERROR', 5)}"
			raise
		end

		def debug_prompt
			fmt(:white, 'debug> ')
		end
	end
end