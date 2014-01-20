class RUITest::Action
	# Load the specified file into an isolated variable context and execute
	# the actions specified. If the file does not exist, this action fails.
	# See #tryload for a similar action that skips if the file does not exist.
	#
	# +file+ can a path relative to the current test file.
	#
	# An optional list of variables can be provided in +vars+. These variables
	# will override the value of the context variables for the execution of the
	# file (See Context#with_vars).
	#
	# The syntax of the variable specification is:
	#     "var1_name=var1_value" "var2_name=var2_value" ...
	#
	# :category: Action Methods
	def load(file, *vars)
		tryload(file, *vars) || (raise Errors::FileNotFoundError, "File not found: #{file}")
	end
end
