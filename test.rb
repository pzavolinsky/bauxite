#!/usr/bin/env ruby

require 'optparse'
require_relative  File.join('core', 'Context.rb')

options = {
	:logger   => 'xterm',
	:verbose  => false,
	:break    => false,
	:provider => 'firefox',
	:debug    => false,
	:timeout  => 10,
	:reset    => false
}

cmd = File.basename(__FILE__)

OptionParser.new do |opts|
	opts.banner = "Usage: #{cmd} [options] [files...]"
	
	opts.separator ""
	opts.separator "Options: "
	opts.on("-v", "--verbose", "Show verbose errors")                              { |v| options[:verbose ] = v }
	opts.on("-l", "--logger LOGGER", "Logger type ('#{options[:logger]}')")        { |v| options[:logger  ] = v }
	opts.on("-w", "--wait", "Wait for ENTER before exiting")                       { |v| options[:wait    ] = v }
	opts.on("-p", "--provider", "Driver provider")                                 { |v| options[:driver  ] = v }
	opts.on("-d", "--debug", "Break to debug on error. "+
	                         "Start the debug console if no input files given.")   { |v| options[:debug   ] = v }
	opts.on("-t", "--timeout SECONDS", "Selector timeout (#{options[:timeout]}s)") { |v| options[:timeout ] = v }
	opts.on("-r", "--reset", "Reset driver between tests")                         { |v| options[:reset   ] = v }
	
	opts.separator ""
	opts.separator "Loggers:"
	Context::loggers.sort.each do |s|
		opts.separator "    #{s}"
	end
	
	opts.separator ""
	opts.separator "Actions:".ljust(33)+"Selectors:"
	actions = Context::actions.sort
	selectors = Context::selectors.sort
	[actions.size, selectors.size].max.times.zip(actions, selectors).each do |idx,a,s|
		a = a ? "#{a.ljust(7)} #{Context.action_args(a).join(' ')}" : ''
		opts.separator "    #{a.ljust(33)}#{s || ''}"
	end
	
	opts.separator ""
end.parse!

ctx = Context.new(options)

files = ARGV
files = ['stdin'] if files.size == 0 and not options[:debug]

actions = ctx.handle_errors do
	files.map do |file|
		ctx.parse_action("load \"#{file.gsub('"', '""')}\"")
	end
end

if options[:reset] and files.size > 1
	actions = actions.map { |a| [a] }.inject do |sum,a|
		sum += [ctx.parse_action('reset')]
		sum + a
	end.flatten
end

if options[:debug] and actions.size == 0
	actions = [ctx.parse_action('debug')] 
end

ctx.start(actions)
