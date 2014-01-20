module RUITest
	# Errors Module
	module Errors
		# Error raised when an assertion fails.
		# 
		class AssertionError < StandardError
		end
		
		# Error raised when an invalid file tried to be loaded.
		# 
		class FileNotFoundError < StandardError
		end
	end
end