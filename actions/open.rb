class Bauxite::Action
	# Opens the specified +url+ in the browser.
	#
	# For example:
	#     open "http://www.ruby-lang.org"
	#     # => this would open http://www.ruby-lang.org in the browser window
	#
	# :category: Action Methods
	def open(url)
		@ctx.driver.navigate.to url
	end
end
