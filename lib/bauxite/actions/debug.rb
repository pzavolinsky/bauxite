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
	# Breaks into the debug console.
	#
	# In the debug console you can type action strings and test their result.
	#
	# The debug console supports a history of previously executed actions and
	# autocomplete (pressing the +TAB+ key).
	#
	# For example:
	#     debug
	#     # => this breaks into the debug console
	# :category: Action Methods
	def debug
		lambda do
			@ctx.with_vars({ '__DEBUG__' => true }) do
				_debug_process
			end
		end
	end
	
private
	@@debug_line = 0
	def _debug_process
		Readline.completion_append_character = " "
		Readline.completer_word_break_characters = ""
		Readline.completion_proc = lambda { |str| _debug_auto_complete(str) }
		
		while line = _debug_get_line
			next if not line or line == ''
			break if line == 'exit'
			@ctx.handle_errors(false, false) do
				@ctx.exec_action({ :text => line, :file => '<debug>', :line => @@debug_line }, true)
			end
			@@debug_line += 1
		end
	end

	def _debug_get_line
		line = Readline.readline(@ctx.logger.debug_prompt, true)
		return nil if line.nil?
		if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
			Readline::HISTORY.pop
		end
		line.strip
	end
	
	def _debug_auto_complete(str)
		action_name = str.sub(/ .*/, '')
		#puts "\n\nac: ==>#{str}<==\nname: ==>#{action_name}<==\n\n"
		
		actions = (Bauxite::Context::actions + ['exit']).grep(/^#{Regexp.escape(action_name)}/)
		
		return actions unless actions.size == 1 and actions[0] == action_name and action_name != 'exit'
		
		args = str.sub(/^\S+ /, '')
		
		data = ['']
		
		if args != ''
			begin
				data = Bauxite::Context::parse_args(args)
			rescue
			#puts "\nhasta aca\n"
				return []
			end
		end
		return [] if data.size == 0
		
		arg_name = Bauxite::Context::action_args(actions[0])[data.size - 1]
		return [] if arg_name != 'selector'
		
		arg_value = data[-1]
		#puts "\n\val: ==>#{arg_value}<==\n\n"
		
		data.pop
		data = data.join('" "')
		data = '"'+data+'" ' if data.size > 0
		
		selectors = Bauxite::Context::selectors.grep(/^#{Regexp.escape(arg_value)}/)
			.map { |s| "#{action_name} #{data}#{s}=" }
	end
end
