class RUITest::Action
	# Asserts that the page source matches +text+.
	#
	# +text+ can be a regular expression.
	#
	# :category: Action Methods
	def source(text)
		actual = @ctx.driver.page_source
		verbose = @ctx.options[:verbose] ? "\nPage source:\n#{actual}" : ''
		unless actual =~ _pattern(text)
			raise AssertionError, "Assertion failed: page source does not match '#{text}'#{verbose}"
		end
	end
end
