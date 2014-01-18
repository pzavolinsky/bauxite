class Action
	def break_action
		lambda { @ctx.wait }
	end
end
