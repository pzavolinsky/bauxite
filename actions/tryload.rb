class Action
	# Load the specified file into an isolated variable context and execute
	# the actions specified. If the file does not exist, this action skips.
	# See #load for a similar action that fails if the file does not exist.
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
	def tryload(file, *vars)
		unless File.exists? file
			current = @ctx.variables['__FILE__']
			current = (File.exists? current) ? File.dirname(current) : Dir.pwd
			file = File.join(current, file)
			return nil unless File.exists? file
		end
		
		var_hash = vars.inject({'__FILE__' => file}) do |h,v|
			data = v.split('=', 2)
			h[data[0]] = data[1]
			h
		end
		
		actions = @ctx.parse_file file
		
		lambda do
			@ctx.with_vars var_hash do
				actions.each { |a| @ctx.exec_action(a) }
			end
		end
	end
end
