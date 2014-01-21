class Bauxite::Action
	# Asserts that the variables named +vars+ are defined and not empty.
	#
	# :category: Action Methods
	def params(*vars)
		missing = vars.select { |v| (@ctx.variables[v] || '') == '' }.join(', ')
		if missing != ''
			raise Bauxite::Errors::AssertionError, 
				"Assertion failed: the following variables must be defined and not be empty: #{missing}."
		end
		true
	end
end
