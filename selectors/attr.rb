class Selector
	def attr(arg, &block)
		data = arg.split(':', 2)
		_find(:css, "[#{data[0]}='#{data[1]}']", &block)
	end
end
