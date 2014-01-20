class RUITest::Action
	# Executes the specified Javascript +script+, optionally storing the
	# results the variable named +name+.
	#
	# Note that if +name+ is provided, the script must return a value using
	# the Javascript +return+ statement.
	#
	# For example:
	#     action.js('return document.title', 'title_var')
	#     # => @ctx.variables['title_var'] should hold the title of the page
	#
	# :category: Action Methods
	def js(script, name = nil)
		result = @ctx.driver.execute_script(script)
		@ctx.variables[name] = result if name
		true
	end
end
