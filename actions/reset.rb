class Action
	# Resets the test engine by closing and reopening the browser. As a side
	# effect of resetting the test engine, all cookies, logins and cache items
	# are destroyed.
	#
	# :category: Action Methods
	def reset()
		@ctx.reset_driver
	end
end