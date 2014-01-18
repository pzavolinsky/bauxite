class Action
	def assert(selector, text)
		@ctx.find(selector) do |e|
			actual = @ctx.get_value(e)
			raise AssertionError, "Assertion failed: expected '#{text}', got '#{actual}'" if not (actual =~ /#{text}/)
		end
	end
end
