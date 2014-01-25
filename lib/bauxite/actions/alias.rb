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

class Bauxite::Action
	# Aliases +name+ to +action+ with additional arguments.
	#
	# In +args+ the variables <tt>${1}</tt>..<tt>${n}</tt> will be expanded
	# to the arguments given to the alias. Also <tt>${n*}</tt> will be expanded
	# to the space separated list of arguments from the n-th on. Finally, 
	# <tt>${n*q}</tt> will behave like <tt>${n*}</tt> except that each argument
	# will be surrounded by quotes (+"+) and quotes inside the argument will be
	# doubled (+""+).
	#
	# Note that +action+ can be any action except +alias+. Also note that
	# this action does not check for cyclic aliases (e.g. alias +a+ to +b+
	# and alias +b+ to +a+). You should check that yourself.
	#
	# Also note that this method provides an action named +alias+ and not
	# alias_action.
	#
	# 
	# For example:
	#     alias hey echo "$1, nice to see you!"
	#     hey john
	#     # => this would expand to
	#     # echo "john, nice to see you!"
	#
	# :category: Action Methods
	def alias_action(name, action, *args)
		@ctx.aliases[name] = ([action] + (args.map { |a| '"'+a.gsub('""', '')+'"' })).join(' ')
	end
end
