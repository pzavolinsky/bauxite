class Bauxite::Action
	# Returns the specified variables to the parent scope (if any).
	#
	# If +vars+ is <tt>*</tt> every variable defined in the current scope
	# will be returned to the parent scope.
	#
	# The syntax of the variable specification is:
	#     "var1_name" "var2_name" ...
	#
	# Note that this method provides an action named +return+ and not
	# return_action.
	#
	# For example:
	#     set result "42"
	#     return result
	#     # => this would inject the result variable (whose value is 42)
	#     #    into the calling context.
	#
	# Full example (see #load, #write, #click, #store and #assert for more
	# details):
	#     # in main.bxt
	#     load login.txt "username=jdoe" "password=hello world!"
	#
	#         # in login.bxt
	#         write id=user "${username}"
	#         write id=pass "${password}"
	#         click id=login
	#         store id=loginName fullName
	#         return fullName
	#
	#     # back in main.bxt
	#     assert id=greeting "Welcome ${fullName}!"
	#     # => this assertion uses the variable returned from login.bxt
	#
	# :category: Action Methods
	def return_action(*vars)
		rets = @ctx.variables['__RETURN__'] || []
		@ctx.variables['__RETURN__'] = rets + vars
	end
end
