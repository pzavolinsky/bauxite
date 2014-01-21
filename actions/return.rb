class Bauxite::Action
	# Returns the specified variables to the parent scope (if any).
	#
	# If +vars+ is <tt>*</tt> every variable defined in the current scope
	# will be returned to the parent scope.
	#
	# The syntax of the variable specification is:
	#     "var1_name" "var2_name" ...
	#
	# :category: Action Methods
	def return_action(*vars)
		rets = @ctx.variables['__RETURN__'] || []
		@ctx.variables['__RETURN__'] = rets + vars
	end
end
