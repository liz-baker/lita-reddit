require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop) do |task|
task.patterns = ['lib/**/*.rb']
  # only show the files with failures
  task.formatters = ['files']
  #     # don't abort rake on failure
  task.fail_on_error = false
end

task :default => [:spec, :rubocop]
