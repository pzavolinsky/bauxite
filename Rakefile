task :default => [:test, :doc]

# === Gem Package =========================================================== #
require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
	s.name        = 'bauxite'
	s.summary     = 'Bauxite is a façade over Selenium intended for non-developers'
	s.author      = 'Patricio Zavolinsky'
	s.email       = 'pzavolinsky at yahoo dot com dot ar'
	s.homepage    = 'http://rubygems.org/gems/bauxite'
	s.license     = 'MIT'
	s.version     = `ruby -Ilib bin/bauxite --version`.gsub(/^.* /, '')
	s.files       = PKG_FILES
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

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

task :package => [ :test, :doc ]
task :gem     => [ :test, :doc ]

# === Integration tests ===================================================== #
desc "Run integration tests"
task :test do
	test_files = Dir[File.join('test', '*.bxt')].select { |f| not File.directory? f }.join(' ')
	ruby "-Ilib bin/bauxite -v #{test_files}"
end

# === Documentation ========================================================= #
desc "Generate Bauxite documentation"
task :doc do
	doc_dirs = ['core','actions','selectors','loggers'].map { |d| File.join('lib', 'bauxite',d,'*') }.join(' ')
	`rdoc -O -U #{doc_dirs}`
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