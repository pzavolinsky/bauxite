class Action
	# Asserts that the value of the selected element matches +text+.
	#
	# +text+ can be a regular expression.
	#
	# :category: Action Methods
	def assert(selector, text)
		@ctx.find(selector) do |e|
			actual = @ctx.get_value(e)
			raise Errors::AssertionError, "Assertion failed: expected '#{text}', got '#{actual}'" unless (actual =~ /#{text}/)
		end
	end
end
