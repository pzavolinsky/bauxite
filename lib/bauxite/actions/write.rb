class Bauxite::Action
	# Sets the value of the selected element to +text+.
	#
	# +text+ is subject to variable expansion (see Context#expand).
	#
	# For example:
	#     # assuming <input type="text" name="username" />
	#     write name=username "John"
	#     # => this would type the word 'John' in the username textbox
	#
	# :category: Action Methods
	def write(selector, text)
		@ctx.find(selector) do |e|
			e.clear
			e.send_keys(text)
		end
	end
end
