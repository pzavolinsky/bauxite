class RUITest::Action
	# Executes +command+, optionally storing the results the variable named 
	# +name+.
	#
	# For example:
	#     action.exec("date --date='2001-01-01' | cut -f 1 -d ' '", 'date')
	#     # => @ctx.variables['date'] == 'Mon'
	#
	# :category: Action Methods
	def exec(command, name = nil)
		ret = `#{command}`
		@ctx.variables[name] = ret.strip if name
	end
end
