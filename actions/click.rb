class Bauxite::Action
	# Triggers the +click+ event on the selected element.
	#
	# :category: Action Methods
	def click(selector)
		@ctx.find(selector) { |e| e.click }
	end
end
