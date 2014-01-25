class Bauxite::Action
	# Executes the specified Javascript +script+, optionally storing the
	# results the variable named +name+.
	#
	# Note that if +name+ is provided, the script must return a value using
	# the Javascript +return+ statement.
	#
	# For example:
	#     js "return document.title" title_var
	#     echo "${title_var}"
	#     # => this would print the title of the page
	#
	# :category: Action Methods
	def js(script, name = nil)
		result = @ctx.driver.execute_script(script)
		@ctx.variables[name] = result if name
		true
	end
end
