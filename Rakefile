require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |gem|
    gem.name = "active_cart"
    gem.summary = "Shopping Cart framework gem. Supports 'storage engines' and order total plugins"
    gem.description = "You can use active_cart as the basis of a shopping cart system. It's not a shopping cart application - it's a shopping cart framework."
    gem.email = "myles@madpilot.com.au"
    gem.homepage = "http://gemcutter.org/gems/active_cart"
    gem.authors = ["Myles Eftos"]
    gem.version = File.exist?('VERSION') ? File.read('VERSION') : ""
    
    gem.add_dependency 'aasm'

    gem.add_development_dependency 'redgreen'
    gem.add_development_dependency 'shoulda'
    gem.add_development_dependency 'mocha'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/unit/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/unit/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "active_cart #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
