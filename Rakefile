task :default => [:test, :doc]

CURRENT_VERSION = `ruby -Ilib bin/bauxite --version`.gsub(/^.* /, '')

# === Gem Package =========================================================== #
require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
	s.name        = 'bauxite'
	s.summary     = 'Bauxite is a façade over Selenium intended for non-developers'
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
	
	ruby "-Ilib bin/bauxite -v -e #{File.join('test', 'extension')} #{File.join('test', 'extension.bxt.manual')}"
	
	system("ruby -Ilib bin/bauxite #{File.join('test', 'test.bxt.manual')}")
	fail "The 'test' action test failed to return the expected exit status: the exit status was #{$?.exitstatus}" unless $?.exitstatus == 2
end

# === Documentation ========================================================= #
desc "Generate Bauxite documentation"
task :doc do
	system("rdoc -O -U -V --main README.md README.md  #{File.join('lib', 'bauxite')}")
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