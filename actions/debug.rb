class Bauxite::Action
	# Breaks into the debug console.
	#
	# In the debug console you can type action strings and test their result.
	#
	# The debug console supports a history of previously executed actions and
	# autocomplete (pressing the +TAB+ key).
	#
	# :category: Action Methods
	def debug
		lambda { _debug_process }
	end
	
private
	@@debug_line = 0
	def _debug_process
		Readline.completion_append_character = " "
		Readline.completer_word_break_characters = ""
		Readline.completion_proc = lambda { |str| _debug_auto_complete(str) }
		
		while line = _debug_get_line
			break if line.strip == 'exit'
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
		line
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
