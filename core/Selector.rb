module Bauxite
	# Selector common state and behavior.
	module SelectorModule
		
		# Constructs a new test selector instance.
		def initialize(ctx)
			@ctx = ctx
		end
		
		# Searches for elements using the specified selector string.
		#
		# For more information see Context#find.
		#
		# Selectors calling this method should forward their block as well.
		#
		# For example:
		#     # === selectors/example.rb ======= #
		#     class Selector
		#         # :category: Selector Methods
		#         def example(arg, &block)
		#             find(arg, &block)
		#         end
		#     end
		#     # === end selectors/example.rb === #
		#
		def find(selector, &block)
			data = selector.split('=', 2)
			type = data.length == 2 ? data[0] : "default"
			raise ArgumentError, "Invalid selector type '#{type}'" unless Context::selectors.include? type
			
			arg  = data[-1]
			return send(type            , arg, &block) if Context::selectors(false).include? type
			return send(type+'_selector', arg, &block) if Context::selectors(false).include? type+'_selector'
			selenium_find(type, arg, &block)
		end
		
	protected
		# Searches for elements using standard Selenium selectors.
		#
		# Selectors calling this method should forward their block as well.
		#
		#     # === selectors/data.rb ======= #
		#     class Selector
		#         # :category: Selector Methods
		#         def data(arg, &block)
		#             # selector code goes here, for example:
		#             selenium_find(:css, "[data='#{arg}']", &block)
		#         end
		#     end
		#     # === end selectors/data.rb === #
		#
		def selenium_find(type, selector)
			element = @ctx.driver.find_element(type, selector)
			yield element if block_given?
			element
		end
	end

	# Selector class.
	#
	# Selectors represent different strategies for finding elements. Selenium
	# provides a list of standard selectors (e.g. by id, by css expression, etc).
	# 
	# Additional selectors can be specified by defining custom methods in the
	# Selector class.
	#
	# Each custom selector is defined in a separate file in the 'selectors/'
	# directory.
	# The name of the file must match the name of the selector. These files should
	# avoid adding public methods other than the selector method itself.
	# Also, no +attr_accessors+ should be added.
	#
	# Selector methods can use the +ctx+ attribute to refer to the current test
	# Context. The protected method #selenium_find can also be used to locate elements
	# using standard Selenium selectors.
	#
	# Selector methods should always take a block and forward that block to a call
	# to either #find or #selenium_find.
	#
	# For example (new selector template):
	#     # === selectors/data.rb ======= #
	#     class Selector
	#         # :category: Selector Methods
	#         def data(arg, &block)
	#             # selector code goes here, for example:
	#             selenium_find(:css, "[data='#{arg}']", &block)
	#         end
	#     end
	#     # === end selectors/data.rb === #
	#
	#     Context::selectors.include? 'data' # => true
	#
	# To avoid name clashing with Ruby reserved words, the '_selector' suffix can
	# be included in the selector method name (this suffix will not be considered
	# part of the selector name).
	#
	# For example (_selector suffix):
	#     # === selectors/end.rb ======= #
	#     class Selector
	#         # :category: Selector Methods
	#         def end_selector
	#             # do something
	#         end
	#     end
	#     # === end selector/end.rb === #
	#
	#     Context::selectors.include? 'end' # => true
	#
	class Selector
		include SelectorModule
	end
end