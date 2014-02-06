task :default => [:test, :doc]

CURRENT_VERSION = `ruby -Ilib bin/bauxite --version`.gsub(/^.* /, '')

# === Gem Package =========================================================== #
require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
	s.name        = 'bauxite'
	s.summary     = 'Bauxite is a façade over Selenium intended for non-developers'
	s.description = 'Bauxite is a façade over Selenium intended for non-developers. The idea behind this project was to create a tool that allows non-developers to write web tests in a human-readable language. Another major requirement is to be able to easily extend the test language to create functional abstractions over technical details.'
	s.author      = 'Patricio Zavolinsky'
	s.email       = 'pzavolinsky at yahoo dot com dot ar'
	s.homepage    = 'https://github.com/pzavolinsky/bauxite'
	s.license     = 'MIT'
	s.version     = CURRENT_VERSION
	s.executables = ["bauxite"]
	s.add_runtime_dependency     'selenium-webdriver', '~> 2.39'
	s.add_development_dependency 'rake'              , '~> 10.1'
	s.files = FileList[
		'LICENSE',
		'README.md',
		'Rakefile',
		'bin/*',
		'lib/**/*.rb',
		'test/**/*',
		'doc/**/*'
	]
end

task :package => [ :test, :doc ]
task :gem     => [ :test, :doc ]

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

# === Integration tests ===================================================== #
desc "Run integration tests"
task :test do
	test_files = Dir[File.join('test', '*.bxt')].select { |f| not File.directory? f }.join(' ')
	ruby "-Ilib bin/bauxite -v #{test_files}"
	
	ruby "-Ilib bin/bauxite -v -e test/extension #{File.join('test', 'extension.bxt.manual')}"
	
	ruby "-Ilib bin/bauxite -v -s css test/default_selector.bxt.manual"
	
	system("ruby -Ilib bin/bauxite test/test.bxt.manual")
	fail "The 'test' action test failed to return the expected exit status: the exit status was #{$?.exitstatus}" unless $?.exitstatus == 2

	debug = `echo exit | ruby -Ilib bin/bauxite -l echo test/debug.bxt.manual -d`
	puts debug
	unless debug.include? 'debug> '
		fail "The -d argument failed to open the debug console"
	end

	check = lambda { |f| fail "Captured file not found #{f}" unless File.exists? f }

	system('rm -rf /tmp/bauxite-test')
	ruby "-Ilib bin/bauxite --output /tmp/bauxite-test test/capture.bxt.manual"
	check.call '/tmp/bauxite-test/test_capture_bxt_manual_0.png'
	check.call '/tmp/bauxite-test/test_capture_bxt_manual_1.png'
	check.call '/tmp/bauxite-test/test_capture_bxt_manual_2.png'
	check.call '/tmp/bauxite-test/with_name.png'
	check.call '/tmp/bauxite-test/capture_my_test_bxt_test_capture_my_test_bxt_3.png'
	check.call '/tmp/bauxite-test/named_test_test_capture_my_test_bxt_3.png'

	system('rm -rf /tmp/bauxite-test')
	system("ruby -Ilib bin/bauxite --output /tmp/bauxite-test -c test/capture_on_error.bxt.manual")
	fail "The 'capture_on_error' test failed to return the expected exit status: the exit status was #{$?.exitstatus}" unless $?.exitstatus == 1
	check.call '/tmp/bauxite-test/capture_on_error_my_test_bxt_test_capture_on_error_bxt_manual_0.png'
	check.call '/tmp/bauxite-test/test_capture_on_error_bxt_manual_0.png'
	
	system("( cd test; ruby -I../lib ../bin/bauxite bug_load_path.bxt.manual -v; )")
	fail "The regression test for 'bug_load_path' failed" unless $?.exitstatus == 0
	
end

# === Documentation ========================================================= #
desc "Generate Bauxite documentation"
task :doc do
	doc = `rdoc -O -U -V --main README.md README.md  #{File.join('lib', 'bauxite')}`
	puts doc
	fail "Documentation failed" unless $?.exitstatus == 0
	fail "Undocumented artifacts found" unless doc.include? '100.00% documented'
end

desc "Open documentation in a browser"
task :viewdoc => [:doc] do
	`xdg-open #{File.join('doc', 'index.html')}`
end

# === Helpers =============================================================== #
desc "Helper: Inject license into every file in lib"
task :inject_license do
	license = File.open('LICENSE', 'r') { |f| f.read }
	license = license.each_line.to_a[2..-1].map { |l| "# #{l}".sub(/ *$/, '') }
	license = "#--\n#{license.join('')}#++\n\n"
	
	Dir['lib/**/*'].select { |f| not File.directory? f }.each do |f|
		puts f
		content = license + File.open(f, 'r') { |f| f.read }
		#File.open(f, 'w') { |f| f.write content }
	end
end

desc "Helper: Update Bauxite version"
task :update_version, :version do |t,args|
	version = args[:version]
	unless version
		puts "Usage rake update_version[version]"
		puts ""
		puts "Current version: #{CURRENT_VERSION}"
		exit false
	end
	
	content = File.open('lib/bauxite.rb', 'r') { |f| f.read }
	expr = /(.*VERSION = ")([^"]*)(".*)/
	
	content = content.each_line.map do |line|
		line.sub(/(.*VERSION = ").*(".*)/, "\\1#{version}\\2")
	end.join
	if version
		puts "Updated version to #{version}"
		File.open('lib/bauxite.rb', 'w') { |f| f.write content }
	end
end