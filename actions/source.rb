class Bauxite::Action
	# Asserts that the page source matches +text+.
	#
	# +text+ can be a regular expression.
	#
	# :category: Action Methods
	def source(text)
		@ctx.with_timeout Bauxite::Errors::AssertionError do
			actual = @ctx.driver.page_source
			verbose = @ctx.options[:verbose] ? "\nPage source:\n#{actual}" : ''
			unless actual =~ _pattern(text)
				raise Bauxite::Errors::AssertionError, "Assertion failed: page source does not match '#{text}'#{verbose}"
			end
			true
		end
	end
end
