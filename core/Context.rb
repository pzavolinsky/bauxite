require "selenium-webdriver"
require "csv"

# The Main test context. This class includes state and helper functions
# used by clients execute tests and by actions and selectors to interact
# with the test engine (i.e. Selenium WebDriver).
class Context
	# Test engine driver instance (Selenium WebDriver).
	attr_reader :driver
	
	# Logger instance.
	attr_reader :logger
	
	# Test options.
	attr_reader :options
	
	# Context variables.
	attr_accessor :variables
	
	# Constructs a new test context instance.
	def initialize(logger, options)
		@logger  = logger
		@options = options
		@variables = {
			'selector_timeout' => options[:timeout].to_i
		}
	end
	
	# Starts the test engine and executes the actions specified. If no action
	# was specified, returns without stopping the test engine (see #stop).
	#
	# For example:
	#     lines = [
	#         'open "http://www.ruby-lang.org"',
	#         'write "name=q" "ljust"',
	#         'click "name=sa"',
	#         'break'
	#     ]
	#     ctx.start(:firefox, 
	#         lines.map { |l| ctx.parse_line(l) }
	#     )
	#     # => navigates to www.ruby-lang.org, types ljust in the search box
	#     #    and clicks the "Search" button.
	#
	def start(driver_name, actions = [])
		@driver = Selenium::WebDriver.for driver_name
		return unless actions.size > 0
		begin
			actions.each do |action|
				exec_action(action)
			end
		ensure
			stop
		end
	end
	
	# Stops the test engine.
	#
	# Calling this method at the end of the test is mandatory if #start was
	# called without +actions+.
	#
	# Note that the recommeneded way of executing tests is by passing a list
	# of +actions+ to #start instead of using the #start / #stop pattern.
	#
	# For example:
	#     ctx.start(:firefox) # => opens firefox
	#
	#     # test stuff goes here
	#
	#     ctx.stop            # => closes firefox
	#
	def stop
		Context::wait if @options[:wait]
		@driver.quit
	end
	
	# Finds an element by +selector+.
	#
	# The element found is yielded to the given +block+ (if any) and returned.
	#
	# Note that the recommeneded way to call this method is by passing a 
	# +block+. This is because the method ensures that the element context is
	# maintained for the duration of the +block+ but it makes no guarantees
	# after the +block+ completes (the same applies if no +block+ was given).
	#
	# For example:
	#     ctx.find('css=.my_button') { |element| element.click }
	#     ctx.find('css=.my_button').click
	#
	# For example (where using a +block+ is mandatory):
	#     ctx.find('frame=|myframe|css=.my_button') { |element| element.click }
	#     # => .my_button clicked
	#
	#     ctx.find('frame=|myframe|css=.my_button').click
	#     # => error, cannot click .my_button (no longer in myframe scope)
	#
	def find(selector, &block) # yields: element
		Selector.new(self).find(selector, &block)
	end
	
	# Breaks into the debug console.
	#
	# For example:
	#     ctx.debug
	#     # => this breaks into the debug console
	def debug
		Action.new(self).debug.call
	end
	
	# Returns the value of the specified +element+.
	#
	# This method takes into account the type of element and selectively
	# returns the inner text or the value of the +value+ attribute.
	#
	# For example:
	#     # assuming <input type='text' value='Hello' />
	#     #          <span id='label'>World!</span>
	#     
	#     ctx.get_value(ctx.find('css=input[type=text]'))
	#     # => returns 'Hello'
	#     
	#     ctx.get_value(ctx.find('label'))
	#     # => returns 'World!'
	#
	def get_value(element)
		return element.attribute('value') if ['input','select','textarea'].include? element.tag_name.downcase
		element.text
	end
	
	# ======================================================================= #
	# :section: Advanced Helpers
	# ======================================================================= #
	
	# Executes the specified action handling errors, logging and debug history.
	# Actions can be obtained by calling #parse_line.
	#
	# For example:
	#     action = ctx.parse_line('open "http://www.ruby-lang.org"')
	#     ctx.exec_action action
	#     # => navigates to www.ruby-lang.org
	#
	def exec_action(action)
		ret = handle_errors(true) do
			@logger.log_cmd(action[:cmd], action[:args].call) do
		    	Readline::HISTORY << action[:text]
				action[:exec].call
			end
		end
		ret.call if ret.respond_to? :call # delayed actions (after log_cmd)
	end

	# Parses the specified text into a test action.
	#
	# The action items returned by this method can be passed to #exec_action to
	# execute the action. The arguments and execution lambdas apply variable
	# expansion throught the #expand method.
	#
	# For example:
	#     ctx.parse_line('echo "!"', 'test.txt' 3)
	#     # => {
	#     #        :cmd  => 'echo',
	#     #        :args => lambda, # returns expandad action arguments
	#     #        :exec => lambda, # executes the action
	#     #        :text => 'echo "!"'
	#     #    }
	#
	def parse_line(text, file = '<unknown>', line = 0)
		action = Action.new(self)
		data = text.split(' ', 2)
		cmd = data[0].strip.downcase
		cmd_real = (action.respond_to? cmd) ? cmd : (cmd+'_action')
		raise "#{file} (line #{line+1}): Unknown command #{cmd}." unless action.respond_to? cmd_real
		
		args = data[1] ? data[1].strip : ''
		begin
			args = Context::parse_args(args) || []
		rescue CSV::MalformedCSVError => e
			raise "#{file} (line #{line+1}): #{e.message}"
		end
		
		{
			:cmd  => cmd,
			:args => lambda { args.map { |a| self.expand(a) } },
			:exec => lambda { action.send(cmd_real, *(args.map { |a| self.expand(a) })) },
			:text => text
		}
	end
	
	# Parses a line of action text into an array. The input +line+ should be a
	# space-separated list of values, surrounded by optional quotes (").
	# 
	# The first element in +line+ will be interpreted as an action name. Valid
	# action names are retuned by ::actions.
	#
	# The other elements in +line+ will be interpreted as action arguments.
	#
	# For example:
	#     Context::parse_args('echo "Hello World!"')
	#     # => ' ["echo", "Hello World!"]
	#
	def self.parse_args(line)
		CSV.parse_line(line, { :skip_blanks => true, :col_sep => ' ' })
	end
	
	# Executes the +block+ inside a rescue block applying standard criteria of
	# error handling.
	#
	# The default behavior is to print the exception message and exit.
	#
	# If the +:verbose+ option is set, the exception backtrace will also be
	# printed.
	#
	# If the +break_into_debug+ argument is +true+ and the +:debug+ option is
	# set, the handler will break into the debug console instead of exiting.
	#
	# For example:
	#     ctx = Context.new(Logger.new(), { :debug => true })
	#     ctx.handle_errors(true) { raise 'break into debug now!' }
	#     # => this breaks into the debug console
	#
	def handle_errors(break_into_debug = false)
		yield
	rescue StandardError => e
		puts e.message
		puts e.backtrace if @options[:verbose]
		if break_into_debug and @options[:debug]
			debug
		else
			exit
		end
	end
	
	# Prompts the user to press ENTER before resuming execution.
	#
	# For example:
	#     Context::wait
	#     # => echoes "Press ENTER to continue" and waits for user input
	#
	def self.wait
		Readline.readline("Press ENTER to continue\n")
	end
	
	# ======================================================================= #
	# :section: Metadata
	# ======================================================================= #
	
	# Returns an array with the names of every action available.
	#
	# For example:
	#     Context::actions
	#     # => [ "assert", "break", ... ]
	#
	def self.actions
		_action_methods.map { |m| m.sub(/_action$/, '') }
	end
		
	# Returns an array with the names of the arguments of the specified action.
	#
	# For example:
	#     Context::action_args 'assert'
	#     # => [ "selector", "text" ]
	#
	def self.action_args(action)
		action += '_action' unless _action_methods.include? action
		Action.public_instance_method(action).parameters.map { |att, name| name.to_s }
	end

	# Returns an array with the names of every selector available.
	#
	# For example:
	#     Context::selectors
	#     # => [ "class", "id", ... ]
	#
	def self.selectors
		Selector.public_instance_methods(false).map { |a| a.to_s.sub(/_selector$/, '') } \
		- [ 'find', 'default' ] \
		+ Selenium::WebDriver::SearchContext::FINDERS.map { |k,v| k.to_s }
	end
	
	# ======================================================================= #
	# :section: Variable manipulation methods
	# ======================================================================= #
	
	# Recursively replaces occurencies of variable expansions in +s+ with the
	# corresponding variable value.
	#
	# The variable expansion expression format is:
	#     '${variable_name}'
	#
	# For example:
	#     ctx.variables = { 'a' => '1', 'b' => '2', 'c' => 'a' }
	#     ctx.expand '${a}'    # => '1'
	#     ctx.expand '${b}'    # => '2'
	#     ctx.expand '${c}'    # => 'a'
	#     ctx.expand '${${c}}' # => '1'
	#
	def expand(s)
		result = @variables.inject(s) do |s,kv|
			s = s.gsub(/\$\{#{kv[0]}\}/, kv[1].to_s)
		end
		result = expand(result) if result != s
		result
	end
	
	# Temporarily alter the value of context variables.
	#
	# This method alters the value of the variables specified in the +vars+
	# hash for the duration of the given +block+. When the +block+ completes,
	# the original value of the context variables is restored.
	#
	# For example:
	#     ctx.variables = { 'a' => '1', 'b' => '2', c => 'a' }
	#     ctx.with_vars({ 'a' => '10', d => '20' }) do
	#        p ctx.variables
	#        # => {"a"=>"10", "b"=>"2", "c"=>"a", "d"=>"20"}
	#     end
	#     p ctx.variables
	#     # => {"a"=>"1", "b"=>"2", "c"=>"a"}
	#
	def with_vars(vars)
		current = @variables
		@variables = @variables.merge(vars)
		yield
	ensure
		@variables = current
	end
	
private
	def self._action_methods
		Action.public_instance_methods(false).map { |a| a.to_s }
	end
end
