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

require 'optparse'
require_relative  'core/context'

module Bauxite
	# +bauxite+ command-line program.
	# 
	# This program executes Bauxite tests and outputs the execution progress
	# and tests results to the terminal.
	#
	# == Synopsis
	#
	#    bauxite [OPTIONS] file1 file2 ...
	#    # => Executes file1, then file2, and so on.
	#    
	#    bauxite [OPTIONS] -d
	#    # => Start Bauxite directly in the debug console.
	#    
	#    bauxite [OPTIONS]
	#    # => Start Bauxite and read test actions from the standard input.
	#
	# == Options
	# For a detailed list of options for your Bauxite version execute:
	#    bauxite -h
    #
	#
	# [-v, \--verbose]
	#     Show verbose error messages (i.e. print exception names and
	#     backtraces).
	#
	# [-t, \--timeout SECONDS]
	#     Number of seconds to wait before issuing a timeout error. This
	#     timeout applies only to Selectors. 
	#
	# [-d, \--debug]
	#     If an error occurs, break into the debug console. This mode is very
	#     useful to try different selector combinations and debug
	#     NoSuchElementError errors.
	#
	# [-p, \--provider DRIVER]
	#     Selenium WebDriver provider. Defaults to +firefox+.
	#
	#     Other options include:
	#     - +remote+
	#     - +ie+
	#     - +chrome+
	#     - +android+
	#     - +iphone+
	#     - +opera+
	#     - +phantomjs+
	#     - +safari+
	#
	#     Driver availability dependes on the system running Bauxite.
	# [-P, \--provider-option OPTION] 
	#    A <tt>name=value</tt> pair of options that are directly forwarded to
	#    the Selenium WebDriver provider. This option argument can appear
	#    multiple times in the command line to specify multiple options.
	#
	# [-l, \--logger LOGGER]
	#    Logger instance to use. Defaults to +xterm+ if the +TERM+ environment
	#    variable is set to +xterm+, otherwise it defaults to +terminal+.
	#
	#    To see a complete list of the available loggers execute:
	#        bauxite -h
	#
	# [-L, \--logger-option OPTION]
	#    A <tt>name=value</tt> pair of options that are directly forwarded to
	#    the logger. This option argument can appear multiple times in the
	#    command line to specify multiple options.
	#
	# [-r, \--reset]
	#    Issue a Action#reset action between every test specified in
	#    the command line. This option enforces test isolation by resetting
	#    the test context before each test (this removes cookies, sessions,
	#    etc. from the previous test).
	#
	# [-w, \--wait]
	#    Wait for user input when the test completes instead of closing the
	#    browser window.
	#
	# [-u, \--url URL]
	#    This option is an alias of:
	#        -p remote -P url=URL
	#    If +URL+ is not present <tt>http://localhost:4444/wd/hub</tt> will be
	#    assumed.
	#
	# [-e, \--extension DIR]
	#    Loads every Ruby file (*.rb) inside +DIR+ (and subdirectories). This
	#    option can be used to load custom Bauxite extensions (e.g. Actions, 
	#    Selectors, Loggers, etc.) for a specific test run.
	#
	#    For example:
	#        # === custom/my_selector.rb ======= #
	#        class Bauxite::Selector
	#            def by_attr(value)
	#                attr "by_attr:#{value}"
	#            end
	#        end
	#        # === end custom/my_selector.rb === #
	#
	#        # === custom/my_test.bxt ========== #
	#        # ...
	#        assert "by_attr=attr_value" hello
	#        # ...
	#        # === end custom/my_test.bxt ====== #
	#
	#        bauxite -e custom custom/my_test.bxt
	#
	# [\--version]
	#     Shows the Bauxite version.
	#
	# == Exit Status
	# The +bauxite+ program exits with +zero+ if every action in the test
	# succeeded and +non-zero+ otherwise.
	# 
	# If the test run includes multiple Action#test actions, the exit status
	# equals the number of failed test cases (again, +zero+ indicates success).
	#
	class Application
		def self.start #:nodoc:
			options = {
				:logger     => (ENV['TERM'] == 'xterm') ?  'xterm' : 'terminal',
				:verbose    => false,
				:break      => false,
				:driver     => 'firefox',
				:debug      => false,
				:timeout    => 10,
				:reset      => false,
				:driver_opt => {},
				:logger_opt => {},
				:extensions => []
			}

			OptionParser.new do |opts|
				opts.banner = "Usage: bauxite [options] [files...]"
				
				def opts.o=(o)
					@o = o
				end
				def opts.single(*args)
					on(*args[1..-1]) do |v|
						@o[args[0]] = v
					end
					self
				end
				def opts.multi(*args)
					on(*args[1..-1]) do |v|
						n,v = v.split('=', 2)
						@o[args[0]][n.to_sym] = v || true
					end
					self
				end
				opts.o = options

				opts.separator ""
				opts.separator "Options: "
				opts
				.single(:verbose   , "-v",  "--verbose", "Show verbose errors")
				.single(:timeout   , "-t",  "--timeout SECONDS", "Selector timeout (#{options[:timeout]}s)")
				.single(:debug     , "-d",  "--debug", "Break to debug on error. "+
													"Start the debug console if no input files given.")
				.single(:driver    , "-p",  "--provider PROVIDER"     , "Driver provider")
				.multi( :driver_opt, "-P",  "--provider-option OPTION", "Provider options (name=value)")
				.single(:logger    , "-l",  "--logger LOGGER"         , "Logger type ('#{options[:logger]}')")
				.multi( :logger_opt, "-L",  "--logger-option OPTION"  , "Logger options (name=value)")
				.single(:reset     , "-r",  "--reset"                 , "Reset driver between tests")
				.single(:wait      , "-w",  "--wait"                  , "Wait for ENTER before exiting")
				opts.on("-u", "--url [URL]", "Configure the remote provider listening in the given url.") do |v|
					v = 'localhost:4444' unless v
					v = 'http://'+v unless v.match /^https?:\/\//
					v = v + '/wd/hub' unless v.end_with? '/wd/hub'
					options[:driver] = 'remote'
					options[:driver_opt][:url] = v
				end
				opts.on("-e", "--extension DIR", "Load extensions from DIR") { |v| options[:extensions] << v }
				opts.on("--version", "Show version") do
					puts "bauxite #{Bauxite::VERSION}"
					exit
				end
				
				opts.separator ""
				opts.separator "Loggers:"
				Context::loggers.sort.each do |s|
					opts.separator "    #{s}"
				end
				
				opts.separator ""
				opts.separator "Selectors:".ljust(32)+" Actions:"
				max_action_size = Context::max_action_name_size
				selectors = Context::selectors.sort
				actions   = Context::actions.sort
				[selectors.size, actions.size].max.times.zip(selectors, actions).each do |idx,s,a|
					a = a ? "#{a.ljust(max_action_size)} #{Context.action_args(a).join(' ')}" : ''
					s = '' unless s
					opts.separator "    #{s.ljust(28)}     #{a}"
				end
				
				opts.separator ""
			end.parse!

			ctx = Context.new(options)

			files = ARGV
			files = ['stdin'] if files.size == 0 and not options[:debug]

			actions = files.map { |f| "load \"#{f.gsub('"', '""')}\"" }

			if options[:reset] and files.size > 1
				actions = actions.map { |a| [a] }.inject do |sum,a|
					sum += ['reset']
					sum + a
				end.flatten
			end

			if options[:debug] and actions.size == 0
				actions = ['debug'] 
			end

			begin
				ctx.start(actions)
			ensure
				if ctx.tests.any?
					
					failed = 0
					
					puts
					puts 'Test summary:'
					puts '============='
					puts 'Name'.ljust(40 ) + ' Time'.ljust(7 ) + ' Status'.ljust(7)+' Error'
					puts ''.ljust(40, '-') + ' '.ljust(7, '-') + ' '.ljust(7, '-' )+' '.ljust(5, '-')
					ctx.tests.each do |t|
						error = t[:error]
						error = error ? error.message : ''
						puts t[:name].ljust(40) + ' ' + t[:time].round(2).to_s.rjust(6) + ' ' + t[:status].ljust(6) + ' ' + error
						failed += 1 if t[:status] != 'OK'
					end
					exit failed if failed > 0
				end
			end
		end
	end
end