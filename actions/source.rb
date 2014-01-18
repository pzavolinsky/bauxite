class Action
	def source(text)
		actual = @ctx.driver.page_source
		verbose = @ctx.options[:verbose] ? "\nPage source:\n#{actual}" : ''
		raise AssertionError, "Assertion failed: page source does not match '#{text}'#{verbose}" if not (actual =~ /#{text}/)
	end
end
