# frozen_string_literal: true

require_relative "lib/codeowners_rs/version"

Gem::Specification.new do |spec|
  spec.name = "codeowners_rs"
  spec.version = CodeownersRs::VERSION
  spec.authors = ["Reid Lynch"]
  spec.email = ["rlynch@wrapbook.com"]

  spec.summary = "A Ruby CODEOWNERS parser powered by Rust"
  spec.homepage = "https://github.com/wrapbook/codeowners_rs"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  spec.files = Dir[
    "lib/**/*.rb",
    "exe/**/*",
    "ext/**/*.{rs,rb,toml}",
    "**/Cargo.{toml,lock}",
    "README.md",
    "LICENSE.txt"
  ]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/codeowners_rs/extconf.rb"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "rb_sys", "~> 0.9.124"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
