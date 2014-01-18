require 'optparse'
require 'readline'

# Load custom actions and selectors
Dir[File.dirname(__FILE__)+'/core/*.rb'     ].each { |file| require file }
Dir[File.dirname(__FILE__)+'/actions/*.rb'  ].each { |file| require file }
Dir[File.dirname(__FILE__)+'/selectors/*.rb'].each { |file| require file }

options = { :log => 'bash', :verbose => false, :break => false, :provider => 'firefox', :debug => false, :timeout => 10 }
OptionParser.new do |opts|
  opts.banner = "Usage: test.rb [options]"
  opts.on("-v", "--[no-]verbose", "Show verbose errors")   { |v| options[:verbose ] = v }
  opts.on("-l", "--log TYPE", "Logger type ('bash')")      { |v| options[:log     ] = v }
  opts.on("-w", "--wait", "Wait for ENTER before exiting") { |v| options[:wait    ] = v }
  opts.on("-p", "--provider", "Driver provider")           { |v| options[:provider] = v }
  opts.on("-d", "--debug", "Debug")                        { |v| options[:debug   ] = v }
  opts.on("-t", "--timeout SECONDS", "Selector timeout")   { |v| options[:timeout ] = v }
end.parse!

if options[:log] != ''
	Dir[File.dirname(__FILE__)+"/loggers/#{options[:log]}.rb"  ].each { |file| require file }
end

ctx = Context.new(Logger.new, options)

actions = ctx.handle_errors do
	ARGV.map do |file|
		ctx.logger.log_cmd('load', [file]) do
			File.open(file).each_line.each_with_index.map do |text,line|
				{ :file => file, :line => line, :text => text.sub(/\r?\n$/, '') }
			end
		end
	end
	.flatten
	.select { |item| not (item[:text] =~ /^\s*(#|$)/) }
	.map do |item|
		ctx.parse_line(item)
	end
end

if actions.size > 0
	ctx.start(options[:provider].to_sym, actions)
else
	ctx.start(options[:provider].to_sym)
	ctx.debug
end
