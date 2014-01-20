lambda do |ctx|
	raise "Failed" if ctx.variables['message'] != "a message to ruby!"
	ctx.exec_action 'set response "response from ruby!"'
	ctx.exec_action 'return response'
end
