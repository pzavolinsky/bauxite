class RUITest::Action
	# Asserts that the +actual+ text matches the +expected+ text.
	#
	# +expected+ can be a regular expression.
	#
	# :category: Action Methods
	def assertv(expected, actual)
		raise Errors::AssertionError, "Assertion failed: '#{actual}' does not match '#{expected}'" unless (actual =~ /#{expected}/)
		true
	end
end
