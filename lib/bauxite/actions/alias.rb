class Bauxite::Action
	# Aliases +name+ to +action+ with additional arguments.
	#
	# In +args+ the variables <tt>${1}</tt>..<tt>${n}</tt> will be expanded
	# to the arguments given to the alias. Also <tt>${n*}</tt> will be expanded
	# to the space separated list of arguments from the n-th on. Finally, 
	# <tt>${n*q}</tt> will behave like <tt>${n*}</tt> except that each argument
	# will be surrounded by quotes (+"+) and quotes inside the argument will be
	# doubled (+""+).
	#
	# Note that +action+ can be any action except +alias+. Also note that
	# this action does not check for cyclic aliases (e.g. alias +a+ to +b+
	# and alias +b+ to +a+). You should check that yourself.
	#
	# Also note that this method provides an action named +alias+ and not
	# alias_action.
	#
	# 
	# For example:
	#     alias hey echo "$1, nice to see you!"
	#     hey john
	#     # => this would expand to
	#     # echo "john, nice to see you!"
	#
	# :category: Action Methods
	def alias_action(name, action, *args)
		@ctx.aliases[name] = ([action] + (args.map { |a| '"'+a.gsub('""', '')+'"' })).join(' ')
	end
end
