class RUITest::Action
	# Wait for the specified number of +seconds+.
	# 
	# :category: Action Methods
	def wait(seconds)
		seconds = seconds.to_i
		seconds.times do |i|
			@ctx.logger.progress(seconds-i)
			sleep(1.0)
		end
	end
end
