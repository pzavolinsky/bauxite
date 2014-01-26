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
	
	#--
	# Adapted from:
	#   https://github.com/jimweirich/rake/blob/master/lib/rake/application.rb
	# See Rake::Application#terminal_width
	#++
	def _screen_width
		if RbConfig::CONFIG['host_os'] =~
        /(aix|darwin|linux|(net|free|open)bsd|cygwin|solaris|irix|hpux)/i
			(_dynamic_width_stty.nonzero? || _dynamic_width_tput)
		else
			super
		end
	rescue Exception => e
		super
	end
    def _dynamic_width_stty
      %x{stty size 2>/dev/null}.split[1].to_i
    end
    def _dynamic_width_tput
      %x{tput cols 2>/dev/null}.to_i
    end
end