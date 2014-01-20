class RUITest::Action
	# Executes +command+, optionally storing the results in a variable.
	#
	# If the first argument of +command+ is <tt>name=...</tt> the results
	# of the execution will be assigned to the variable named +name+.
	#
	# For example:
	#     action.exec("date=date --date='2001-01-01' | cut -f 1 -d ' '")
	#     # => @ctx.variables['date'] == 'Mon'
	#
	# :category: Action Methods
	def exec(*command)
		data = command[0].split('=', 2)
		name = nil
		if (data.size == 2)
			name = data[0]
			command[0] = data[1]
		end

		ret = `#{command.join(' ')}`
		@ctx.variables[name] = ret.strip if name
	end
end
