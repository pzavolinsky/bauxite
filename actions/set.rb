class Bauxite::Action
	# Sets the variable named +name+ to the +value+ specified.
	#
	# Both +name+ and +value+ are subject to variable expansion
	# (see Context#expand).
	#
	# For example:
	#     set one "uno"
	#     set two "${one} + ${one}"
	#     echo "${two}"
	#     # => this would print 'uno + uno'
	#
	# :category: Action Methods
	def set(name, value)
		@ctx.variables[name] = value
	end
end
