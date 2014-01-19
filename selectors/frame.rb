class Selector
	# Change the selector scope to the given frame and finds an element in that
	# frame.
	#
	# This is a composite selector. The frame selector syntax is:
	#     frame=|frame_selector|child_selector
	#
	# Where +frame_selector+ is any selector available that matches the target
	# frame, +child_selector+ is any selector available that matches the target
	# element inside the target frame.
	#
	# Note that the '|' character can be replaced with any single-character
	# delimiter.
	#
	# Also note that frame selectors can be embedded to select a frame inside
	# a frame. To accompilish this, +child_selector+ can be a frame selector.
	#
	# For example:
	#     # assuming <iframe class="myframe">
	#     #            <div id="child">...</div>
	#     #          </iframe>
	#     ctx.find('frame=|css=.myframe|child')
	#     # => matches the 'child' element above.
	#
	# :category: Selector Methods
	def frame(arg, &block)
		delimiter = arg[0]
		items = arg[1..-1].split(delimiter, 2)
		frame = find(items[0])
		
		begin
			@ctx.driver.switch_to.frame frame
			find(items[1], &block)
		ensure
			@ctx.driver.switch_to.default_content
		end
	end
end
