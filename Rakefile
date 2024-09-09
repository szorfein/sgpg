# frozen_string_literal: true

require 'rake/testtask'
require File.dirname(__FILE__) + '/lib/sgpg/version'

# run rake
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/test_*.rb']
end

# Usage: rake gem:build
namespace :gem do
  desc 'build the gem'
  task :build do
  Dir['sgpg*.gem'].each { |f| File.unlink(f) }
    system('gem build sgpg.gemspec')
    system("gem install sgpg-#{Sgpg::VERSION}.gem -P HighSecurity")
  end
end

task default: :test
