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
		_load_file_action(file, *vars) do |f|
			actions = @ctx.parse_file(f)
			lambda { actions.each { |a| @ctx.exec_action(a) } }
		end
	end
	
private
	def _load_file_action(file, *vars)
		unless File.exists? file
			current = @ctx.variables['__FILE__']
			current = (File.exists? current) ? File.dirname(current) : Dir.pwd
			file = File.join(current, file)
			return nil unless File.exists? file
		end
		
		var_hash = vars.inject({}) do |h,v|
			data = v.split('=', 2)
			h[data[0]] = data[1]
			h
		end
		
		execution_lambda = yield file
		
		lambda do
			ret_vars = nil
			@ctx.with_vars var_hash do
				execution_lambda.call
				rets = @ctx.variables['__RETURN__']
				ret_vars = @ctx.variables.select { |k,v| rets.include? k } if rets
			end
			@ctx.variables.merge!(ret_vars) if ret_vars
		end
	end
end
