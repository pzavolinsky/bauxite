#!/usr/bin/env ruby

require 'fileutils'

dir = File.dirname(__FILE__)

puts "=== Running tests ==="
test_files = Dir[File.join(dir,'tests', '*')].select { |f| not File.directory? f }.join(' ')
unless system("ruby test.rb #{test_files}")
	puts "=== Tests failed! ==="
end

puts ""
puts "=== Building documentation ==="
doc_dirs = ['core','actions','selectors','loggers'].map { |d| File.join(dir,d,'*') }.join(' ')
doc_target = File.join(dir, 'doc')
FileUtils.rm_r doc_target if Dir.exists? doc_target
system("rdoc -o #{doc_target} #{doc_dirs}")
