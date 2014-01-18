class Selector
	def frame(arg, &block)
		def frame_scope(frame)
			@ctx.driver.switch_to.frame frame
			yield
		ensure
			@ctx.driver.switch_to.default_content
		end

		delimiter = arg[0]
		items = arg[1..-1].split(delimiter, 2)
		frame = find(items[0])
		frame_scope frame do
			find(items[1], &block)
		end
	end
end
