require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "pbkdf2-ruby"
    gem.summary = %Q{Password-Based Key Derivation Function 2 - PBKDF2}
    gem.description = %Q{This implementation conforms to RFC 2898, and has been tested using the test vectors in Appendix B of RFC 3962. Note, however, that while those specifications use HMAC-SHA-1, this implementation defaults to HMAC-SHA-256. (SHA-256 provides a longer bit length. In addition, NIST has stated that SHA-1 should be phased out due to concerns over recent cryptanalytic attacks.)}
    gem.email = "quigley@emerose.com"
    gem.homepage = "http://github.com/emerose/pbkdf2-ruby"
    gem.authors = ["Sam Quigley"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "rdoc", ">= 2.4.2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ["--color", "--format progress", "-r ./spec/spec_helper.rb"]
  spec.pattern = 'spec/**/*_spec.rb'
end

task :spec => :check_dependencies

task :default => :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pbkdf2 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
