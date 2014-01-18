class Action
	# Asserts that the value of the selected element matches +text+.
	#
	# +text+ can be a regular expression.
	#
	# :category: Action Methods
	def assert(selector, text)
		@ctx.find(selector) do |e|
			actual = @ctx.get_value(e)
			raise AssertionError, "Assertion failed: expected '#{text}', got '#{actual}'" if not (actual =~ /#{text}/)
		end
	end
end
