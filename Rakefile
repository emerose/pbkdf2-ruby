require 'rspec/core/rake_task'
require 'pbkdf2'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pbkdf2 #{PBKDF2::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
