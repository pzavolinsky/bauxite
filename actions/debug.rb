class Action
	@@debug_line = 0

	def debug
		lambda { _debug_process }
	end
	
private
	def _debug_process
		Readline.completion_append_character = " "
		Readline.completer_word_break_characters = ""
		Readline.completion_proc = Proc.new do |str|
			_debug_auto_complete(str)
		end
		
		while line = _debug_get_line
			break if line == 'exit'
			@@debug_line += 1
	  		@ctx.exec_action(@ctx.parse_command({
	  			:file => '<debug>',
	  			:line => @@debug_line,
	  			:text => line
	  		}))
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
		
		actions = @ctx.actions.grep(/^#{Regexp.escape(action_name)}/)
		return actions if actions.size != 1 or actions[0] != action_name
		
		args = str.sub(/^\S+ /, '')
		
		data = ['']
		
		if args != ''
			begin
				data = @ctx.parse_args(args)
			rescue
			#puts "\nhasta aca\n"
				return []
			end
		end
		return [] if data.size == 0
		
		arg_name = @ctx.action_args(actions[0])[data.size - 1]
		return [] if arg_name != 'selector'
		
		arg_value = data[-1]
		#puts "\n\val: ==>#{arg_value}<==\n\n"
		
		data.pop
		data = data.join('" "')
		data = '"'+data+'" ' if data.size > 0
		
		selectors = @ctx.selectors.grep(/^#{Regexp.escape(arg_value)}/)
			.map { |s| "#{action_name} #{data}#{s}=" }
	end
end
