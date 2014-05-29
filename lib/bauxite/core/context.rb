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

require 'selenium-webdriver'
require 'readline'
require 'csv'
require 'pathname'

# Load dependencies and extensions without leaking dir into the global scope
lambda do
	dir = File.expand_path(File.dirname(__FILE__))
	Dir[File.join(dir,                    '*.rb')].each { |file| require file }
	Dir[File.join(dir, '..', 'actions'  , '*.rb')].each { |file| require file }
	Dir[File.join(dir, '..', 'selectors', '*.rb')].each { |file| require file }
	Dir[File.join(dir, '..', 'loggers'  , '*.rb')].each { |file| require file }
	Dir[File.join(dir, '..', 'parsers'  , '*.rb')].each { |file| require file }
end.call

# Bauxite Namespace
module Bauxite
	# The Main test context. This class includes state and helper functions
	# used by clients execute tests and by actions and selectors to interact
	# with the test engine (i.e. Selenium WebDriver).
	#
	# === Context variables
	# Context variables are a key/value pairs scoped to the a test context.
	#
	# Variables can be set using different actions. For example:
	# - Action#set sets a variable to a literal string.
	# - Action#store sets a variable to the value of an element in the page.
	# - Action#exec sets a variable to the output of an external command
	#   (i.e. stdout).
	# - Action#js sets a variable to the result of Javascript command.
	# - Action#replace sets a variable to the result of doing a 
	#   find-and-replace operation on a literal.
	#
	# Variables can be expanded in every Action argument (e.g. selectors,
	# texts, expressions, etc.). To obtain the value of a variable through
	# variable expansion the following syntax must be used:
	#     ${var_name}
	#
	# For example:
	#     set field "greeting"
	#     set name "John"
	#     write "${field}_textbox" "Hi, my name is ${name}!"
	#     click "${field}_button"
	#
	# === Variable scope
	# When the main test starts (via the #start method), the test is bound
	# to the global scope. The variables defined in the global scope are
	# available to every test Action.
	#
	# The global scope can have nested variable scopes created by special
	# actions. The variables defined in a scope +A+ are only available to that
	# scope and scopes nested within +A+.
	#
	# Every time an Action loads a file, a new nested scope is created.
	# File-loading actions include:
	# - Action#load
	# - Action#tryload
	# - Action#ruby
	# - Action#test
	#
	# A nested scope can bubble variables to its parent scope with the special
	# action:
	# - Action#return_action
	#
	# === Built-in variable
	# Bauxite has a series of built-in variables that provide information of
	# the current test context and allow dynamic constomizations of the test
	# behavior.
	#
	# The built-in variables are:
	# [<tt>__FILE__</tt>] The file where the current action is defined.
	# [<tt>__DIR__</tt>] The directory where <tt>__FILE__</tt> is.
	# [<tt>__SELECTOR__</tt>] The default selector used when the selector
	#                         specified does not contain an <tt>=</tt>
	#                         character.
	# [<tt>__DEBUG__</tt>] Set to true if the current action is being executed
	#                      by the debug console.
	# [<tt>__RETURN__</tt>] Used internally by Action#return_action to indicate
	#                       which variables should be returned to the parent
	#                       scope.
	#
	# In general, variables surrounded by double underscores and variables
	# whose names are only numbers are reserved for Bauxite and should not be
	# used as part of a functional test. The obvious exception is when trying
	# to change the test behavior by changing the built-in variables.
	#
	class Context
		# Logger instance.
		attr_reader :logger
		
		# Test options.
		attr_reader :options
		
		# Context variables.
		attr_accessor :variables
		
		# Test containers.
		attr_accessor :tests

		# Constructs a new test context instance.
		#
		# +options+ is a hash with the following values:
		# [:driver] selenium driver symbol (defaults to +:firefox+)
		# [:timeout] selector timeout in seconds (defaults to +10s+)
		# [:logger] logger implementation name without the 'Logger' suffix
		#           (defaults to 'null' for Loggers::NullLogger).
		# [:verbose] if +true+, show verbose error information (e.g.
		#            backtraces) if an error occurs (defaults to +false+)
		# [:debug] if +true+, break into the #debug console if an error occurs
		#          (defaults to +false+)
		# [:wait] if +true+, call ::wait before stopping the test engine with
		#         #stop (defaults to +false+)
		# [:extensions] an array of directories that contain extensions to be
		#               loaded
		#
		def initialize(options)
			@options = options
			@driver_name = (options[:driver] || :firefox).to_sym
			@variables = {
				'__TIMEOUT__'  => (options[:timeout] || 10).to_i,
				'__DEBUG__'    => false,
				'__SELECTOR__' => options[:selector] || 'sid',
				'__OUTPUT__'   => options[:output],
				'__DIR__'      => File.absolute_path(Dir.pwd)
			}
			@aliases = {}
			@tests = []
			
			client = Selenium::WebDriver::Remote::Http::Default.new
			client.timeout = (@options[:open_timeout] || 60).to_i
			@options[:driver_opt] = {} unless @options[:driver_opt]
			@options[:driver_opt][:http_client] = client

			_load_extensions(options[:extensions] || [])
			
			@logger = Context::load_logger(options[:logger], options[:logger_opt])
			
			@parser = Parser.new(self)
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
		#     ctx.start(lines)
		#     # => navigates to www.ruby-lang.org, types ljust in the search box
		#     #    and clicks the "Search" button.
		#
		def start(actions = [])
			return unless actions.size > 0
			begin
				actions.each do |action|
					begin
						break if exec_action(action) == :break
					rescue StandardError => e
						print_error(e)
						raise unless @options[:debug]
						debug
					end
				end
			ensure
				stop
			end
		end
		
		# Stops the test engine and starts a new engine with the same provider.
		#
		# For example:
		#     ctx.reset_driver
		#     => closes the browser and opens a new one
		#
		def reset_driver
			@driver.quit if @driver
			@driver = nil
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
			begin
				@logger.finalize(self)
			rescue StandardError => e
				print_error(e)
				raise
			ensure
				@driver.quit if @driver
			end
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
			with_timeout Selenium::WebDriver::Error::NoSuchElementError do
				Selector.new(self, @variables['__SELECTOR__']).find(selector, &block)
			end
		end
		
		# Test engine driver instance (Selenium WebDriver).
		def driver
			_load_driver unless @driver
			@driver
		end
		
		# Breaks into the debug console.
		#
		# For example:
		#     ctx.debug
		#     # => this breaks into the debug console
		def debug
			exec_parsed_action('debug', [], false)
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
			if ['input','select','textarea'].include? element.tag_name.downcase
				element.attribute('value') 
			else
				element.text
			end
		end
		
		# ======================================================================= #
		# :section: Advanced Helpers
		# ======================================================================= #
		
		# Executes the specified action string handling errors, logging and debug
		# history.
		#
		# If +log+ is +true+, log the action execution (default behavior).
		#
		# For example:
		#     ctx.exec_action 'open "http://www.ruby-lang.org"'
		#     # => navigates to www.ruby-lang.org
		#
		def exec_action(text)
			data = Context::parse_action_default(text, '<unknown>', 0)
			exec_parsed_action(data[:action], data[:args], true, text)
		end
		
		# Executes the specified +file+.
		#
		# For example:
		#     ctx.exec_file('file')
		#     # => executes every action defined in 'file'
		#
		def exec_file(file)
			current_dir  = @variables['__DIR__' ]
			current_file = @variables['__FILE__']
			current_line = @variables['__LINE__']

			@parser.parse(file) do |action, args, text, file, line|
				@variables['__DIR__'] = File.absolute_path(File.dirname(file))
				@variables['__FILE__'] = file
				@variables['__LINE__'] = line
				break if exec_parsed_action(action, args, true, text) == :break
			end

			@variables['__DIR__' ] = current_dir
			@variables['__FILE__'] = current_file
			@variables['__LINE__'] = current_line
		end

		# Executes the specified action handling errors, logging and debug
		# history.
		#
		# If +log+ is +true+, log the action execution (default behavior).
		#
		# This method if part of the action execution chain and is intended
		# for advanced use (e.g. in complex actions). To execute an Action
		# directly, the #exec_action method is preferred.
		#
		# For example:
		#     ctx.exec_action 'open "http://www.ruby-lang.org"'
		#     # => navigates to www.ruby-lang.org
		#
		def exec_parsed_action(action, args, log = true, text = nil)
			action = get_action(action, args, text)
			ret = nil
			if log
				@logger.log_cmd(action) do
					Readline::HISTORY << action.text
					ret = exec_action_object(action)
				end
			else
				ret = exec_action_object(action)
			end

			if ret.respond_to? :call # delayed actions (after log_cmd)
				ret.call
			else
				ret
			end
		rescue Selenium::WebDriver::Error::UnhandledAlertError
			raise Bauxite::Errors::AssertionError, "Unexpected modal present"
		end

		# Executes the given block retrying for at most <tt>${__TIMEOUT__}</tt>
		# seconds. Note that this method does not take into account the time it
		# takes to execute the block itself.
		#
		# For example
		#     ctx.with_timeout StandardError do
		#         ctx.find ('element_with_delay') do |e|
		#             # do something with e
		#         end
		#     end
		#
		def with_timeout(*error_types)
			stime = Time.new
			timeout ||= stime + @variables['__TIMEOUT__']
			yield
		rescue *error_types => e
			t = Time.new
			rem = timeout - t
			raise if rem < 0

			@logger.progress(rem.round)

			sleep(1.0/10.0) if (t - stime).to_i < 1
			retry
		end
		
		# Executes the given block using the specified driver +timeout+.
		#
		# Note that the driver +timeout+ is the time (in seconds) Selenium
		# will wait for a specific element to appear in the page (using any
		# of the available Selector strategies).
		#
		# For example
		#     ctx.with_driver_timeout 0.5 do
		#         ctx.find ('find_me_quickly') do |e|
		#             # do something with e
		#         end
		#     end
		#
		def with_driver_timeout(timeout)
			current = @driver_timeout
			driver.manage.timeouts.implicit_wait = timeout
			yield
		ensure
			@driver_timeout = current
			driver.manage.timeouts.implicit_wait = current
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
		
		# Constructs a Logger instance using +name+ as a hint for the logger
		# type.
		#
		def self.load_logger(loggers, options)
			if loggers.is_a? Array
				return Loggers::CompositeLogger.new(options, loggers)
			end
			
			name = loggers
			
			log_name = (name || 'null').downcase
			
			class_name = "#{log_name.capitalize}Logger"
			
			unless Loggers.const_defined? class_name.to_sym
				raise NameError,
					"Invalid logger '#{log_name}'"
			end
			
			Loggers.const_get(class_name).new(options)
		end
		
		# Adds an alias named +name+ to the specified +action+ with the
		# arguments specified in +args+.
		#
		def add_alias(name, action, args)
			@aliases[name] = { :action => action, :args => args }
		end
		
		# Default action parsing strategy.
		#
		def self.parse_action_default(text, file = '<unknown>', line = 0)
			data = text.split(' ', 2)
			begin
				args_text = data[1] ? data[1].strip : ''
				args = []
				
				unless args_text == ''
					# col_sep must be a regex because String.split has a
					# special case for a single space char (' ') that produced
					# unexpected results (i.e. if line is '"a      b"' the
					# resulting array contains ["a b"]).
					#
					# ...but... 
					#
					# CSV expects col_sep to be a string so we need to work
					# some dark magic here. Basically we proxy the StringIO
					# received by CSV to returns strings for which the split
					# method does not fold the whitespaces.
					#
					args = CSV.new(StringIOProxy.new(args_text), { :col_sep => ' ' })
					.shift
					.select { |a| a != nil } || []
				end
				
				{
					:action => data[0].strip.downcase,
					:args   => args
				}
			rescue StandardError => e
				raise "#{file} (line #{line+1}): #{e.message}"
			end
		end
		
		# Returns an executable Action object constructed from the specified
		# arguments resolving action aliases.
		#
		# This method if part of the action execution chain and is intended
		# for advanced use (e.g. in complex actions). To execute an Action
		# directly, the #exec_action method is preferred.
		#
		def get_action(action, args, text = nil)
			while (alias_action = @aliases[action])
				action = alias_action[:action]
				args   = alias_action[:args].map do |a|
					a.gsub(/\$\{(\d+)(\*q?)?\}/) do |match|
						# expand ${1} to args[0], ${2} to args[1], etc.
						# expand ${4*} to "#{args[4]} #{args[5]} ..."
						# expand ${4*q} to "\"#{args[4]}\" \"#{args[5]}\" ..."
						idx = $1.to_i-1
						if $2 == nil
							args[idx] || ''
						else
							range = args[idx..-1]
							range = range.map { |arg| '"'+arg.gsub('"', '""')+'"' } if $2 == '*q'
							range.join(' ')
						end
					end
				end
			end
			
			text = ([action] + args.map { |a| '"'+a.gsub('"', '""')+'"' }).join(' ') unless text
			file = @variables['__FILE__']
			line = @variables['__LINE__']
			
			Action.new(self, action, args, text, file, line)
		end
		
		# Executes the specified action object injecting built-in variables.
		# Note that the result returned by this method might be a lambda.
		# If this is the case, a further +call+ method must be issued.
		#
		# This method if part of the action execution chain and is intended
		# for advanced use (e.g. in complex actions). To execute an Action
		# directly, the #exec_action method is preferred.
		#
		# For example:
		#     action = ctx.get_action("echo", ['Hi!'], 'echo "Hi!"')
		#     ret = ctx.exec_action_object(action)
		#     ret.call if ret.respond_to? :call
		#
		def exec_action_object(action)
			action.execute
		end

		# Prints the specified +error+ using the Logger configured and 
		# handling the verbose option.
		# 
		# For example:
		#     begin
		#         # => some code here
		#     rescue StandardError => e
		#         @ctx.print_error e
		#         # => additional error handling code here
		#     end
		#
		def print_error(e, capture = true)
			if @logger
				@logger.log "#{e.message}\n", :error
			else
				puts e.message
			end
			if @options[:verbose]
				p e
				puts e.backtrace
			end
			if capture and @options[:capture]
				with_vars(e.variables) do
					exec_parsed_action('capture', [] , false)
					e.variables['__CAPTURE__'] = @variables['__CAPTURE__']
				end
			end
		end
		
		# Returns the output path for +path+ accounting for the 
		# <tt>__OUTPUT__</tt> variable.
		#
		# For example:
		#     # assuming --output /mnt/disk
		#     
		#     ctx.output_path '/tmp/myfile.txt'
		#     # => returns '/tmp/myfile.txt'
		#     
		#     ctx.output_path 'myfile.txt'
		#     # => returns '/mnt/disk/myfile.txt'
		#
		def output_path(path)
			unless Pathname.new(path).absolute?
				output = @variables['__OUTPUT__']
				if output
					Dir.mkdir output unless Dir.exists? output
					path = File.join(output, path)
				end
			end
			path
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
		# If +include_standard_selectors+ is +true+ (default behavior) both
		# standard and custom selector are returned, otherwise only custom 
		# selectors are returned.
		#
		# For example:
		#     Context::selectors
		#     # => [ "class", "id", ... ]
		#
		def self.selectors(include_standard_selectors = true)
			ret = Selector.public_instance_methods(false).map { |a| a.to_s.sub(/_selector$/, '') }
			if include_standard_selectors
				ret += Selenium::WebDriver::SearchContext::FINDERS.map { |k,v| k.to_s }
			end
			ret
		end
		
		# Returns an array with the names of every logger available.
		#
		# For example:
		#     Context::loggers
		#     # => [ "null", "bash", ... ]
		#
		def self.loggers
			Loggers.constants.map { |l| l.to_s.downcase.sub(/logger$/, '') }
		end
		
		# Returns an array with the names of every parser available.
		#
		# For example:
		#     Context::parsers
		#     # => [ "default", "html", ... ]
		#
		def self.parsers
			(Parser.public_instance_methods(false) \
			 - ParserModule.public_instance_methods(false))
			.map { |p| p.to_s }
		end
		
		# Returns the maximum size in characters of an action name.
		#
		# This method is useful to pretty print lists of actions
		#
		# For example:
		#     # assuming actions = [ "echo", "assert", "tryload" ]
		#     Context::max_action_name_size
		#     # => 7
		def self.max_action_name_size
			actions.inject(0) { |s,a| a.size > s ? a.size : s }
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
			ret_vars = nil

			ret = yield
			
			returned = @variables['__RETURN__']
			if returned == ['*']
				ret_vars = @variables.clone
				ret_vars.delete '__RETURN__'
			elsif returned != nil
				ret_vars = @variables.select { |k,v| returned.include? k }
			end
		rescue StandardError => e
			e.instance_variable_set "@variables", @variables
			def e.variables
				@variables
			end
			raise
		ensure
			@variables = current
			@variables.merge!(ret_vars) if ret_vars
			ret
		end
		
	private
		def self._action_methods
			(Action.public_instance_methods(false) \
			 - ActionModule.public_instance_methods(false))
			.map { |a| a.to_s }
		end
		
		def _load_driver
			@driver = Selenium::WebDriver.for(@driver_name, @options[:driver_opt])
			@driver.manage.timeouts.implicit_wait = 1
			@driver_timeout = 1
		end
		
		def _load_extensions(dirs)
			dirs.each do |d|
				d = File.join(Dir.pwd, d) unless Dir.exists? d
				d = File.absolute_path(d)
				Dir[File.join(d, '**', '*.rb')].each { |file| require file }
			end
		end
		
		# ======================================================================= #
		# Hacks required to overcome the String#split(' ') behavior of folding the
		# space characters, coupled with CSV not supporting a regex as :col_sep.
		
		# Same as a common String except that split(' ') behaves as split(/\s/).
		class StringProxy # :nodoc:
			def initialize(s)
				@s = s
			end
			
			def method_missing(method, *args, &block)
				args[0] = /\s/ if method == :split and args.size > 0 and args[0] == ' '
				ret = @s.send(method, *args, &block)
			end
		end
		
		# Same as a common StringIO except that get(sep) returns a StringProxy
		# instead of a regular string.
		class StringIOProxy # :nodoc:
			def initialize(s)
				@s = StringIO.new(s)
			end
			
			def method_missing(method, *args, &block)
				ret = @s.send(method, *args, &block)
				return ret unless method == :gets and args.size == 1
				StringProxy.new(ret)
			end
		end
		# ======================================================================= #
	end
end