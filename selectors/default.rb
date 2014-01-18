class Selector
	# Select an element by id suffix.
	#
	# This is the default selector. Any selector strings that do not contain an
	# equal sign (i.e. '=') will use this selector.
	#
	# For example:
	#     # assuming <div id="strange_uuid_like_stuff_myDiv">...</div>
	#     ctx.find('myDiv')
	#     # => matches the element above.
	#
	# :category: Selector Methods
	def default(arg, &block)
		selenium_find(:css, "[id$='#{arg.gsub("'", "\\'")}']", &block)
	end
end
