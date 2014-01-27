#--
# Copyright (c) 2014 Patricio Zavolinsky
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

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
			# I know I should be using Class scope operators to refer to class
			# methods (i.e. Context::selectors), but for some reason RDoc
			# refuses to document the Selector class (below) if any such
			# operators appear in this method (quite strange). So for now, I'll
			# just settle for using the old and trusty "."
			
			data = selector.split('=', 2)
			type = data.length == 2 ? data[0] : "default"
			raise ArgumentError, "Invalid selector type '#{type}'" unless Context.selectors.include? type
			
			arg  = data[-1]
			custom_selectors = Context.selectors(false)
			return send(type            , arg, &block) if custom_selectors.include? type
			return send(type+'_selector', arg, &block) if custom_selectors.include? type+'_selector'
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
	# ---
	#
	# === Standard Selenium Selectors
	#  
	# [id=+targetValue+]                              {Locate elements whose +id+ attribute matches +targetValue+.}[http://docs.seleniumhq.org/docs/03_webdriver.jsp#by-id]
	# [name=+targetValue+]                            {Locate elements whose +name+ attribute matches +targetValue+.}[http://docs.seleniumhq.org/docs/03_webdriver.jsp#by-name]
	# [css=+cssSelectorSyntax+]                       {Locate elements using CSS selector syntax.}[http://docs.seleniumhq.org/docs/03_webdriver.jsp#by-css]
	# [partial_link_text=+textFragment+]              {Locate A elements whose text includes +textFragment+.}[http://docs.seleniumhq.org/docs/03_webdriver.jsp#by-partial-link-text]
	# [class=+className+ and class_name=+className+]  {Locate elements whose +class+ attribute matches +className+.}[http://docs.seleniumhq.org/docs/03_webdriver.jsp#by-class-name]
	# [link=+exactText+ and link_text=+exactText+]    {Locate A elements whose text is exactly +exactText+.}[http://docs.seleniumhq.org/docs/03_webdriver.jsp#by-link-text]
	# [tag_name=+targetValue+]                        {Locate elements whose tag name matches +targetValue+.}[http://docs.seleniumhq.org/docs/03_webdriver.jsp#by-tag-name]
	# [xpath=+xpathExpression+]                       {Locate elements using XPATH expressions.}[http://docs.seleniumhq.org/docs/03_webdriver.jsp#by-xpath]
	#
	class Selector
		include SelectorModule
		
		# :section: Selector Methods
	end
end