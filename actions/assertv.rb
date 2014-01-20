class RUITest::Action
	# Asserts that the +actual+ text matches the +expected+ text.
	#
	# +expected+ can be a regular expression.
	#
	# :category: Action Methods
	def assertv(expected, actual)
		unless actual =~ _pattern(expected)
			raise Errors::AssertionError, "Assertion failed: '#{actual}' does not match '#{expected}'" 
		end
		true
	end
end
