class Bauxite::Action
	# Replaces the occurrences of +pattern+ in +text+ with +replacement+ and
	# assigns the result to the variable named +name+.
	#
	# For example:
	#     set place "World"
	#     replace "Hello ${place}" "World" "Universe" greeting
	#     echo "${greeting}!"
	#     # => this would print 'Hello Universe!'
	#
	# :category: Action Methods
	def replace(text, pattern, replacement, name)
		@ctx.variables[name] = text.gsub(_pattern(pattern), replacement)
	end
end
