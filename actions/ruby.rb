class Action
	# Load the specified ruby file into an isolated variable context and
	# execute the ruby code.
	#
	# +file+ can a path relative to the current test file.
	#
	# An optional list of variables can be provided in +vars+. See #load.
	#
	# The ruby action file must contain a single lambda that takes a Context
	# instance as its only argument.
	#
	# For example:
	#     # === my_test.rb ======= #
	#     lambda do |ctx|
	#         ctx.exec_action 'echo "Hello World!"'
	#         ctx.driver.navigate.to 'http://www.ruby-lang.org'
	#     end
	#     # === end my_test.rb === #
	#
	# :category: Action Methods
	def ruby(file, *vars)
		# _load_file_action is defined in tryload.rb
		_load_file_action(file, *vars) do |f|
			content = ''
			File.open(f, 'r') { |ff| content = ff.read }
			eval(content).call(@ctx)
		end
	end
end
