class Bauxite::Selector
	# Select an element by attribute value.
	#
	# The attribute selector syntax is:
	#     attr=name:value
	#
	# For example:
	#     # assuming <div custom="true">foo</div>
	#     assert attr=custom:true "foo"
	#     # => matches the element above.
	#
	# :category: Selector Methods
	def attr(arg, &block)
		data = arg.split(':', 2)
		selenium_find(:css, "[#{data[0]}='#{data[1]}']", &block)
	end
end
