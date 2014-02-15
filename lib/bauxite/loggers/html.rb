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

require 'base64'

# Html logger.
#
# This logger creates an HTML report of the test execution, linking to the
# captures taken, if any.
#
# Html logger options include:
# [<tt>html</tt>] Name of the outpus HTML report file. If not present, defaults 
#                 to "test.html".
# [<tt>html_package</tt>] If set, embed captures into the HTML report file
#                         using the data URI scheme (base64 encoded). The
#                         captures embedded into the report are deleted from
#                         the filesystem.
#
class Bauxite::Loggers::HtmlLogger < Bauxite::Loggers::ReportLogger
	
	# Constructs a new null logger instance.
	#
	def initialize(options)
		super(options)
		@file = options[:html] || 'test.html'
		@imgs = []
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
			.status { float: right; text-align: center; }
			.status .text { width: 100px; font-weight: bold }
			.test { background-color: #DFDFFF; margin-top: 20px }
			.ok    .status .text { background-color: #DFFFDF }
			.error .status .text { background-color: #FFDFDF }
			.skip  .status .text { background-color: #FFDFFF }
			.capture { border: 1px solid black }
			.capture img { max-width: 100% }
			.odd { background-color: #EEEEEE }
			.summary th { background-color: #DFDFFF; text-align: left }
			.summary td { cursor: pointer; }
			.top { position: absolute; top: 0px; right: 0px; background-color: #DFDFFF; padding: 5px; border-radius: 0px 0px 0px 5px; }
			
		</style>
		<script type='text/javascript'>
			function show(target) {
				var e = document.getElementById(target+'_content');
				window.location.href = '#'+target;
			}
		</script>
	</head>
	<body>"
		html << _d(2, "<div class='top'>Created using <a href='https://github.com/pzavolinsky/bauxite'>bauxite</a> on #{Time.new}</div>")
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
			html << _d(2, "<div class='test #{status}'>#{name}<div class='status'><div class='text'>#{status.upcase}</div></div></div>")
			html << _d(2, "<div id='#{name}_content' class='test-content'>")
				
			test[:actions].each_with_index do |action,idx|
				html << _d(3, "<div class='action #{action[:status]} #{(idx % 2) == 1 ? 'odd' : 'even'}'>")
				html << _d(4, 	"<div class='cmd'>#{action[:cmd]}</div>")
				html << _d(4, 	"<div class='args'>#{action[:args].join(' ')}</div>")
				html << _d(4, 	"<div class='status'>")
				html << _d(5, 		"<div class='time'>(#{action[:time].round(2).to_s}s)</div>")
				html << _d(5, 		"<div class='text'>#{action[:status].upcase}</div>")
				html << _d(4, 	"</div>")
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
		file = ctx.output_path(@file)
		File.open(file, 'w') { |f| f.write html }
		File.delete(*@imgs) if @imgs.size > 0
	end
	
private
	def _d(depth, s)
		"\n"+depth.times.inject('') { |s,i| s + "\t" } + s
	end
	def _img(output, path)
		if @options[:html_package]
			content = Base64.encode64(File.open(path, 'r') { |f| f.read })
			@imgs << path unless @imgs.include? path
			"<img src='data:image/png;base64,#{content}'/>"
		else
			path = path[output.size+1..-1] unless output == ''
			"<img src='#{path}'/>"
		end
	end
end