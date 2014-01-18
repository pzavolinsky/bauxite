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
	
	# Constructs a new test action instance.
	def initialize(ctx)
		@ctx = ctx
	end
end
