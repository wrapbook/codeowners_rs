# frozen_string_literal: true

module CodeownersRs
  # Ruleset class represents a collection of CODEOWNERS rules
  class Ruleset
    # Rust bindings provide:
    #   attribute :path
    #   attribute :root
    #   attribute :rules
    #   def self.load(path, root)
    #   def self.build(content, root, path)
    #   def rules_for_path(path)
    #   def rule_for_path(path)
    #   def owners_for_path(path)

    def owners_for_constant(constant)
      path = Object.const_source_location(constant.to_s)&.first # [path, line_number]
      path ? owners_for_path(path) : []
    rescue NameError
      []
    end
  end
end
