class RUITest::Action
	# Prompts the user to press ENTER before resuming execution.
	#
	# Note that this method provides an action named +break+ and not
	# break_action.
	#
	# See Context::wait.
	#
	# :category: Action Methods
	def break_action
		lambda { RUITest::Context::wait }
	end
end
