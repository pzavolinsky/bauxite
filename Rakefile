task :default => [:test, :doc]

desc "Run integration tests"
task :test do
	test_files = Dir[File.join('tests', '*.bxt')].select { |f| not File.directory? f }.join(' ')
	ruby "bauxite.rb -v #{test_files}"
end

desc "Generate Bauxite documentation"
task :doc do
	doc_dirs = ['core','actions','selectors','loggers'].map { |d| File.join('lib', 'bauxite',d,'*') }.join(' ')
	`rdoc -O -U #{doc_dirs}`
end

desc "Open documentation in a browser"
task :viewdoc => [:doc] do
	`xdg-open #{File.join('doc', 'index.html')}`
end

desc "Inject license"
task :inject_license do
	license = File.open('LICENSE', 'r') { |f| f.read }
	license = license.each_line.to_a[2..-1].map { |l| "# #{l}".sub(/ *$/, '') }
	license = "#--\n#{license.join('')}#++\n\n"
	
	Dir['lib/**/*'].select { |f| not File.directory? f }.each do |f|
		puts f
		content = license + File.open(f, 'r') { |f| f.read }
		File.open(f, 'w') { |f| f.write content }
	end
end