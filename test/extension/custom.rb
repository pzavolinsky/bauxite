class Bauxite::Action
	def hello()
		lambda { puts 'Hello World!' }
	end
end

class Bauxite::Selector
	def by_attr(value)
		attr "by_attr:#{value}"
	end
end
 
