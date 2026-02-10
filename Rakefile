# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "rb_sys/extensiontask"

GEMSPEC = Gem::Specification.load("codeowners_rs.gemspec")

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

RbSys::ExtensionTask.new("codeowners_rs", GEMSPEC) do |ext|
  ext.lib_dir = "lib/codeowners_rs"
end

desc "Build the native extension and the gem"
task build: :compile

task default: %i[compile spec rubocop]
