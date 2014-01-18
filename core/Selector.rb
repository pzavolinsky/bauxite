class Selector
	attr_accessor :timeout

	def initialize(ctx)
		@ctx = ctx
		@timeout = ctx.selector_timeout
	end
	def find(selector, &block)
		data = selector.split('=', 2)
		type = data.length == 2 ? data[0] : "default"
		raise ArgumentError, 'Invalid selector type "find"' if type == "find"
		
		arg  = data[-1]
		return send(type, arg, &block) if self.respond_to? type
		return send(type+'_selector', arg, &block) if self.respond_to? type+'_selector'
		_find(type, arg, &block)
	end
	
protected
	def _find(type, selector)
		tries ||= @timeout*10
		element = @ctx.driver.find_element(type, selector)
		yield element if block_given?
		element
	rescue Selenium::WebDriver::Error::NoSuchElementError => e
		raise if (tries -= 1).zero?
		@ctx.logger.progress(tries/10) if (tries % 10) == 0
		sleep(1.0/10.0)
		retry
	end
end
