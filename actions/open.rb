class Action
	def open(url)
		@ctx.driver.navigate.to url
	end
end
