require 'optparse'
require_relative  'core/Context.rb'

module Bauxite
	class Application
		def self.start
			options = {
				:logger     => (ENV['TERM'] == 'xterm') ?  'xterm' : 'terminal',
				:verbose    => false,
				:break      => false,
				:driver     => 'firefox',
				:debug      => false,
				:timeout    => 10,
				:reset      => false,
				:driver_opt => {},
				:logger_opt => {}
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

			actions = ctx.handle_errors do
				files.each_with_index.map do |file,idx|
					{
						:text => "load \"#{file.gsub('"', '""')}\"",
						:file => 'command-line-args',
						:line => idx
					}
				end
			end

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
					puts
					puts 'Test summary:'
					puts '============='
					puts 'Name'.ljust(60) + 'Time'.ljust(6) + 'Status'.ljust(7)+'Error'
					ctx.tests.each do |t|
						error = t[:error]
						error = error ? error.message : ''
						puts t[:name].ljust(60) + t[:time].round(3).to_s.ljust(6) + t[:status].ljust(7) + error
					end
				end
			end
		end
	end
end