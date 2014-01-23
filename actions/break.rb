class Bauxite::Action
	# Prompts the user to press ENTER before resuming execution.
	#
	# Note that this method provides an action named +break+ and not
	# break_action.
	#
	# See Context::wait.
	#
	# For example:
	#     break
	#     # => echoes "Press ENTER to continue" and waits for user input
	#
	# :category: Action Methods
	def break_action
		lambda { Bauxite::Context::wait }
	end
end
