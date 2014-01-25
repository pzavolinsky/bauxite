class Bauxite::Action
	# Triggers the +click+ event on the selected element.
	#
	# For example:
	#     # assuming <button type="button" id="btn">click me</button>
	#     click btn
	#     # => this would click the button
	#
	# :category: Action Methods
	def click(selector)
		@ctx.find(selector) { |e| e.click }
	end
end
