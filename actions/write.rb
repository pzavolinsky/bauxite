class Bauxite::Action
	# Sets the value of the selected element to +text+.
	#
	# +text+ is subject to variable expansion (see Context#expand).
	#
	# :category: Action Methods
	def write(selector, text)
		@ctx.find(selector) do |e|
			e.clear
			e.send_keys(text)
		end
	end
end
