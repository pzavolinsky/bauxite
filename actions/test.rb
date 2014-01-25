class Bauxite::Action
	# Load +file+ using the #load action into a new test context.
	#
	# If +name+ is specified, it will be used as the test name.
	#
	# If any action in the test context fails, the whole test context fails,
	# and the execution continues with the next test context (if any).
	#
	# For example:
	#     test mytest.bxt "My Test"
	#     # => this would load mytest.bxt into a new test context
	#     #    named "My Test"
	#
	# :category: Action Methods
	def test(file, name = nil)
		delayed = load(file)

		lambda do
			begin
				t = Time.new
				status = 'ERROR'
				error = nil
				@ctx.with_vars({ '__RAISE_ERROR__' => true }) do
					delayed.call
					status = 'OK'
				end
			rescue StandardError => e
				error = e
			ensure
				@ctx.tests << {
					:name => name || file,
					:status => status,
					:time => Time.new - t,
					:error => error
				}
			end
		end
	end
end
