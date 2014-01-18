class Logger
	def log_cmd(cmd, args)
		yield
	end
	def debug_prompt
		'debug> '
	end
end
