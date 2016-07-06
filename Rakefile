require "bundler/gem_tasks"

require 'rspec/core/rake_task'
namespace :ci do
  desc "Run tests on CI"
  RSpec::Core::RakeTask.new('all') do |t|
    t.verbose = true
    t.rspec_opts = "--tag ~real_data"
  end
end

task :default => "ci:all"
