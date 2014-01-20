# Action common state and behavior.
module ActionModule
	# Parsed action command (i.e. action name)
	attr_reader :cmd
	
	# Raw action text.
	attr_reader :text
	
	# File where the action was defined.
	attr_reader :file
	
	# Line in the #file where the action was defined.
	attr_reader :line
	
	# Constructs a new test action instance.
	def initialize(ctx, cmd, args, text, file, line)
		@ctx  = ctx
		@cmd  = cmd
		@args = args
		@text = text
		@file = file
		@line = line
		
		@cmd_real = (respond_to? cmd+'_action') ? (cmd+'_action') : cmd
		
		unless respond_to? @cmd_real and Context::actions.include? @cmd
			raise "#{file} (line #{line+1}): Unknown command #{cmd}."
		end
	end
	
	# Returns the action arguments after applying variable expansion.
	#
	# See Context#expand.
	#
	# If +quote+ is +true+, the arguments are surrounded by quote
	# characters (") and every quote inside an argument is doubled.
	#
	# For example:
	#     # assuming 
	#     #     action.new(ctx, cmd,
	#     #         [ 'dude', 'say "hi"', '${myvar} ], # args
	#     #         text, file, line)
	#     #     ctx.variables = { 'myvar' => 'world' }
	#     
	#     action.args
	#     # => [ 'dude', 'say "hi"', 'world' ]
	#     
	#     action.args(true)
	#     # => [ '"dude"', '"say ""hi"""', '"world"' ]
	#
	def args(quote = false)
		ret = @args.map { |a| @ctx.expand(a) }
		ret = ret.map { |a| '"'+a.gsub('"', '""')+'"' } if quote
		ret
	end
	
	# Executes the action evaluating the arguments in the current context.
	#
	# Note that #execute calls #args to expand variables. This means that
	# two calls to #execute on the same instance might yield different results.
	#
	# For example:
	#     action = ctx.parse_action('echo ${message}')
	#     
	#     ctx.variables = { 'message' => 'hi!' }
	#     action.execute()
	#     # => outputs 'hi!'
	#     
	#     ctx.variables['message'] = 'hello world'
	#     action.execute()
	#     # => outputs 'hello world!' yet the instance of action is same!
	#
	def execute()
		send(@cmd_real, *args)
	end
end

# Test action class.
#
# Test actions are basic test operations that can be combined to create a test
# case. 
#
# Test actions are implemented as public methods of the Action class.
#
# Each test action is defined in a separate file in the 'actions/' directory.
# The name of the file must match the name of the action. Ideally, these files
# should avoid adding public methods other than the action method itself.
# Also, no +attr_accessors+ should be added.
#
# Action methods can use the +ctx+ attribute to refer to the current test
# Context.
#
# For example (new action template):
#     # === actions/print_source.rb ======= #
#     class Action
#         # :category: Action Methods
#         def print_source
#             # action code goes here, for example:
#             puts @ctx.driver.page_source.
#         end
#     end
#     # === end actions/print_source.rb === #
#
#     Context::actions.include? 'print_source' # => true
#
# To avoid name clashing with Ruby reserved words, the '_action' suffix can be
# included in the action method name (this suffix will not be considered part
# of the action name).
#
# For example (_action suffix):
#     # === actions/break.rb ======= #
#     class Action
#         # :category: Action Methods
#         def break_action
#             # do something
#         end
#     end
#     # === end actions/break.rb === #
#
#     Context::actions.include? 'break' # => true
#
# If the action requires additional attributes or private methods, the name
# of the action should be used as a prefix to avoid name clashing with other
# actions.
#
# For example (private attributes and methods):
#     # === actions/debug.rb ======= #
#     class Action
#         # :category: Action Methods
#         def debug
#             _debug_do_stuff
#         end
#     private
#         @@debug_line = 0
#         def _debug_do_stuff
#             @@debug_line += 1
#         end
#     end
#     # === end actions/debug.rb === #
#
#     Context::actions.include? 'debug' # => true
#
# Action methods support delayed execution of the test action. Delayed
# execution is useful in cases where the action output would break the
# standard logging interface.
#
# Delayed execution is implemented by returning a lambda from the action
# method.
#
# For example (delayed execution):
#     # === actions/break.rb ======= #
#     class Action
#         # :category: Action Methods
#         def break_action
#             lambda { Context::wait }
#         end
#     end
#     # === end actions/break.rb === #
#
#     Context::actions.include? 'debug' # => true
#
# Executing this action would yield something like the following:
#     break                         [ OK  ]
#     Press ENTER to continue
#
# While calling Context::wait directly would yield:
#     break                        Press EN
#     TER to continue
#                                   [ OK  ]
#
class Action
	include ActionModule
end
