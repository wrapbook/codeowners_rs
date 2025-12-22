# frozen_string_literal: true

require_relative "codeowners_rs/version"
require_relative "codeowners_rs/rule"
require_relative "codeowners_rs/ruleset"
require "codeowners_rs/codeowners_rs"

# Top-level module for the CodeownersRs gem
module CodeownersRs
  class Error < StandardError; end

  # Ruby interface matching the Elixir implementation
  class << self
    # Load a CODEOWNERS file and parse it
    # @param path [String] Path to the CODEOWNERS file
    # @param root [String] Root directory for the CODEOWNERS rules
    # @return [Codeowners::Ruleset] Parsed CODEOWNERS Ruleset
    def load(path:, root:)
      Ruleset.load(path, root)
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
