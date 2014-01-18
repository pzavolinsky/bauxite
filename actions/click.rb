class Action
	def click(selector)
		@ctx.find(selector) { |e| e.click }
	end
end
