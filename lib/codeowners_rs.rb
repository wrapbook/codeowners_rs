# frozen_string_literal: true

require_relative "codeowners_rs/version"
require_relative "codeowners_rs/rule"
require_relative "codeowners_rs/ruleset"

begin
  version_dir = RUBY_VERSION.match(/(\d+\.\d+)/).to_a.first # Extract major.minor version (e.g., "3.3")
  require_relative "codeowners_rs/#{version_dir}/codeowners_rs"
rescue LoadError
  require_relative "codeowners_rs/codeowners_rs"
end

# Top-level module for the CodeownersRs gem
module CodeownersRs
  class Error < StandardError; end

  # Ruby interface matching the Elixir implementation
  class << self
    # Load a CODEOWNERS file and parse it
    # @param path [String] Path to the CODEOWNERS file
    # @param root [String] Root directory for the CODEOWNERS rules
    # @return [Codeowners::Ruleset] Parsed CODEOWNERS Ruleset
    def load(path, root: nil)
      Ruleset.load(path.to_s, root)
    end

    # Build a CODEOWNERS object from content string
    # @param content [String] Content of CODEOWNERS file
    # @param root [String] Root directory
    # @param path [String] Path to the CODEOWNERS file (for reference)
    # @return [Codeowners::Ruleset] Parsed CODEOWNERS Ruleset
    def build(content:, root:, path: nil)
      Ruleset.build(content, root, path)
    end
  end
end
