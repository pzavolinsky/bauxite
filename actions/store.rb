class Bauxite::Action
	# Sets the variable named +name+ to the value of the selected element.
	#
	# +name+ is subject to variable expansion (see Context#expand).
	#
	# :category: Action Methods
	def store(selector, name)
		@ctx.find(selector) { |e| @ctx.variables[name] = @ctx.get_value(e) }
	end
end
