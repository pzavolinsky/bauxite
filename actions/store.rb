class Action
	def store(selector, name)
		@ctx.find(selector) { |e| @ctx.variables[name] = @ctx.get_value(e) }
	end
end
