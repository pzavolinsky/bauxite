class Bauxite::Action
	# Asserts that the value of the selected element matches +text+.
	#
	# +text+ is a regular expression. +text+ can be surrounded by +/+ 
	# characters followed by regular expression flags.
	#
	# For example:
	#     # assuming <input type="text" id="hello" value="world" />
	#     assert hello world
	#     assert hello wor
	#     assert hello ^wor
	#     assert hello /WorlD/i
	#     # => these assertions would pass
	#
	# :category: Action Methods
	def assert(selector, text)
		@ctx.with_timeout Bauxite::Errors::AssertionError do
			@ctx.find(selector) do |e|
				actual = @ctx.get_value(e)
				unless actual =~ _pattern(text)
					raise Bauxite::Errors::AssertionError, "Assertion failed: expected '#{text}', got '#{actual}'"
				end
				true
			end
		end
	end
end
