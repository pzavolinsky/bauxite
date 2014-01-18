require "selenium-webdriver"
require "csv"

class Context
	attr_reader :driver, :logger, :selector_timeout, :options, :variables
	
	def initialize(logger, options)
		@logger  = logger
		@options = options
		@selector_timeout = options[:timeout].to_i
		@variables = {}
	end
	
	def start(driver_name, actions)
		@driver = Selenium::WebDriver.for driver_name
		return if not actions
		begin
			actions.each do |action|
				ret = exec_action(action)
				ret.call if ret.respond_to? :call
			end
		ensure
			wait if @options[:wait]
			@driver.quit
		end
	end
	
	def find(selector, &block)
		Selector.new(self).find(selector, &block)
	end
	
	def wait
		Readline.readline("Press ENTER to continue\n")
	end
	
	def debug
		Action.new(self).debug
	end
	
	def get_value(element)
		return element.attribute('value') if ['input','select','textarea'].include? element.tag_name.downcase
		element.text
	end
	
	# === Advanced Helpers ================================================== #
	def exec_action(action)
		handle_errors(true) do
			@logger.log_cmd(action[:cmd], action[:args].call) do
		    	Readline::HISTORY.push(action[:text])
				action[:exec].call
			end
		end
	end

	def parse_line(item)
		action = Action.new(self)
		data = item[:text].split(' ', 2)
		cmd = data[0].downcase
		cmd_real = (action.respond_to? cmd) ? cmd : (cmd+'_action')
		raise "#{item[:file]} (line #{item[:line]+1}): Unknown command #{cmd}." if not action.respond_to? cmd_real
		
		begin
			args = data[1] ? parse_args(data[1]) : []
		rescue CSV::MalformedCSVError => e
			raise "#{item[:file]} (line #{item[:line]+1}): #{e.message}"
		end

		
		{
			:cmd  => cmd,
			:args => lambda { args.map { |a| self.expand(a) } },
			:exec => lambda { action.send(cmd_real, *(args.map { |a| self.expand(a) })) },
			:text => item[:text]
		}
	end
	
	def parse_args(line)
		CSV.parse_line(line, { :skip_blanks => true, :col_sep => ' ' })
	end
	
	def handle_errors(debug = false)
		yield
	rescue StandardError => e
		puts e.message
		puts e.backtrace if @options[:verbose]
		if debug and @options[:debug]
			Action.new(self).debug 
		else
			exit
		end
	end
	
	# === Metadata ========================================================== #
	def actions
		Action.public_instance_methods(false).map { |a| a.to_s.sub(/_action$/, '') }
	end
	
	def action_args(action)
		Action.public_instance_method(:write).parameters.map { |att, name| name.to_s }
	end

	def selectors
		Selector.public_instance_methods(false).map { |a| a.to_s.sub(/_selector$/, '') } \
		- Selector.new(self).instance_variables.map { |v| v = v.to_s.sub(/^@/,''); [ v, v+'='] }.flatten \
		- [ 'find', 'default' ] \
		+ Selenium::WebDriver::SearchContext::FINDERS.map { |k,v| k.to_s }
	end
	
	# === Variables ========================================================= #
	def expand(s)
		result = @variables.inject(s) do |s,kv|
			s = s.gsub(/\$\{#{kv[0]}\}/, kv[1])
		end
		result = expand(result) if result != s
		result
	end
end
