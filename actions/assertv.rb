class Bauxite::Action
	# Asserts that the +actual+ text matches the +expected+ text.
	#
	# +expected+ can be a regular expression.
	#
	# For example:
	#     # assuming ctx.variables['myvar'] = 'myvalue1234'
	#     assertv "^myvalue\d+$" "${myvar}"
	#     # => this assertion would pass
	#
	# :category: Action Methods
	def assertv(expected, actual)
		unless actual =~ _pattern(expected)
			raise Bauxite::Errors::AssertionError, "Assertion failed: '#{actual}' does not match '#{expected}'" 
		end
		true
	end
end
