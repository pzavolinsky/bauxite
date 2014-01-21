class Bauxite::Action
	# Asserts that the value of the selected element matches +text+.
	#
	# +text+ can be a regular expression.
	#
	# :category: Action Methods
	def assert(selector, text)
		@ctx.with_timeout Bauxite::Errors::AssertionError do
			@ctx.find(selector) do |e|
				actual = @ctx.get_value(e)
				unless actual =~ _pattern(text)
					raise Bauxite::Errors::AssertionError, "Assertion failed: expected '#{text}', got '#{actual}'"
				end
			end
		end
	end
end
