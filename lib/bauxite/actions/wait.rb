class Bauxite::Action
	# Wait for the specified number of +seconds+.
	# 
	# For example:
	#     wait 5
	#     # => this would wait for 5 seconds and then continue
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
