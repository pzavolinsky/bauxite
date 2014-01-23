class Bauxite::Action
	# Prints the value of the specified +text+.
	#
	# +text+ is subject to variable expansion (see Context#expand).
	#
	# For example:
	#     echo "Hello World!"
	#     # => this would print "Hello World!" in the terminal window.
	#
	# :category: Action Methods
	def echo(text)
		true
	end
end
