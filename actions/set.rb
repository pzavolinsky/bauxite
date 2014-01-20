class RUITest::Action
	# Sets the variable named +name+ to the +value+ specified.
	#
	# Both +name+ and +value+ are subject to variable expansion
	# (see Context#expand).
	#
	# :category: Action Methods
	def set(name, value)
		@ctx.variables[name] = value
	end
end
