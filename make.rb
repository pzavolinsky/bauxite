#!/usr/bin/env ruby

require 'fileutils'

dir = File.dirname(__FILE__)

def do_step?(step, implicit = true)
	(ARGV.size == 0 and implicit) or (['all', step ] & ARGV).size > 0
end

if do_step? 'test'
	puts "=== Running tests ==="
	test_files = Dir[File.join(dir,'tests', '*.bxt')].select { |f| not File.directory? f }.join(' ')
	unless system("ruby bauxite.rb #{test_files} -v")
		puts "=== Tests failed! ==="
	end
end

doc_target = File.join(dir, 'doc')
if do_step? 'doc'
	puts ""
	puts "=== Building documentation ==="
	doc_dirs = ['core','actions','selectors','loggers'].map { |d| File.join(dir,d,'*') }.join(' ')
	FileUtils.rm_r doc_target if Dir.exists? doc_target
	system("rdoc -U -V -D -o #{doc_target} #{doc_dirs}")
end

if do_step?('doc-view', false) and 
	`xdg-open #{File.join(doc_target, 'index.html')}`
end