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

# Echo logger.
#
# This logger outputs the raw action text for every action executed.
#
# Note that this logger does not include execution status information
# (i.e. action succeeded, failed or was skipped).
#
class Bauxite::Loggers::HtmlLogger < Bauxite::Loggers::NullLogger
	
	# Constructs a new null logger instance.
	#
	def initialize(options)
		super(options)
		@data = []
		@file = options[:html] || 'test.html'
	end
	
	# Logs the specified string.
	#
	# +type+, if specified, should be one of +:error+, +:warning+,
	# +:info+ (default), +:debug+.
	#
	def log(s, type = :info)
	end
			
	# Echoes the raw action text.
	def log_cmd(action)
		ret = yield
	ensure
		status = case ret; when nil; :error; when false; :skip; else :ok; end
		
		test_name = action.ctx.variables['__TEST__'] || 'Main'
		test = @data.find { |t| t[:name] == test_name }
		unless test
			test = { :name => test_name, :actions => [] }
			@data << test
		end
		
		capture = action.ctx.variables['__CAPTURE__']
		if capture == @last_capture
			capture = nil
		else
			@last_capture = capture
		end
		
		test[:actions] << {
			:cmd => action.cmd,
			:args => action.args(true),
			:action => action,
			:status => status,
			:capture => capture
		}
		
		ret
	end
	
	# Completes the log execution.
	#
	def finalize(ctx)
		output = ctx.variables['__OUTPUT__'] || ''
		
		html = "<!DOCTYPE html>
<html>
	<head>
		<style type='text/css'>
			body { font: 10pt sans-serif; }
			.action div { display: inline-block; }
			.cmd { width: 100px }
			.status { width: 100px; float: right; text-align: center; font-weight: bold }
			.test { background-color: #DFDFFF; margin-top: 20px }
			.ok    .status { background-color: #DFFFDF }
			.error .status { background-color: #FFDFDF }
			.skip  .status { background-color: #FFDFFF }
			.capture { border: 1px solid black }
			.capture img { max-width: 100% }
			.odd { background-color: #EEEEEE }
			.summary th { background-color: #DFDFFF; text-align: left }
			.summary td { cursor: pointer; }
			
		</style>
		<script type='text/javascript'>
			function show(target) {
				var e = document.getElementById(target+'_content');
				window.location.href = '#'+target;
			}
		</script>
	</head>
	<body>"
	
		if ctx.tests.any?
			html << _d(2, "<h1>Test Summary</h1>")
			html << _d(2, "<table class='summary'>")
			html << _d(3, "<tr><th>Name</th><th>Time</th><th>Status</th><th>Error</th></tr>")
		
			ctx.tests.each_with_index do |t,idx|
				error = t[:error]
				error = error ? error.message : ''
				html << _d(3, "<tr class='#{t[:status].downcase} #{(idx % 2) == 1 ? 'odd' : 'even'}' onclick='show(\"#{t[:name]}\")'>")
				html << _d(4, "<td>#{t[:name]}</td><td>#{t[:time].round(2)}</td><td class='status'>#{t[:status]}</td><td>#{error}</td>")
				html << _d(3, "</tr>")
			end
			
			html << _d(2, "</table>")
		end
		
		html << _d(2, "<h1>Test Details</h1>")
		@data.each do |test|
			name = test[:name]
			status = test[:actions].find { |a| a[:status] == :error } ? :error : :ok
			html << _d(2, "<a name='#{name}'></a>")
			html << _d(2, "<div class='test #{status}'>#{name}<div class='status'>#{status.upcase}</div></div>")
			html << _d(2, "<div id='#{name}_content' class='test-content'>")
				
			test[:actions].each_with_index do |action,idx|
				html << _d(3, "<div class='action #{action[:status]} #{(idx % 2) == 1 ? 'odd' : 'even'}'>")
				html << _d(4, 	"<div class='cmd'>#{action[:cmd]}</div>")
				html << _d(4, 	"<div class='args'>#{action[:args].join(' ')}</div>")
				html << _d(4, 	"<div class='status'>#{action[:status].upcase}</div>")
				html << _d(3, "</div>")
				capture = action[:capture]
				if capture
					html << _d(3, "<div class='capture'>#{_img(output, capture)}</div>")
				end
			end
			
			item = ctx.tests.find { |t| t[:name] == name }
			if item and item[:error]
				capture = item[:error].variables['__CAPTURE__']
				if capture
					html << _d(3, "<div class='capture'>#{_img(output, capture)}</div>")
				end
			end
			
			html << _d(2, "</div>")
		end
		html << "
	</body>
</html>"
		file = @file
		if output != ''
			file = File.join(output, file)
			Dir.mkdir output unless Dir.exists? output
		end
		File.open(file, 'w') { |f| f.write html }
	end
	
private
	def _d(depth, s)
		"\n"+depth.times.inject('') { |s,i| s + "\t" } + s
	end
	def _img(output, path)
		path = path[output.size+1..-1] unless output == ''
		"<img src='#{path}'/>"
	end
end