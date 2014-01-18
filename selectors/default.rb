class Selector
	def default(arg, &block)
		_find(:css, "[id$='#{arg.gsub("'", "\\'")}']", &block)
	end
end
