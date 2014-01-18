class Action
	# Opens the specified +url+ in the browser.
	#
	# :category: Action Methods
	def open(url)
		@ctx.driver.navigate.to url
	end
end
