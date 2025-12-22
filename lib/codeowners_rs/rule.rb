# frozen_string_literal: true

module CodeownersRs
  # Rule class represents a single CODEOWNERS rule
  class Rule
    # Rust bindings provide:
    #   attribute :pattern
    #   attribute :owners
    #   attribute :line_number
    #   def self.from_line(line, line_number)
    #   def match?(path)

    def to_s
      "#{pattern} #{owners.join(" ")}"
    end

    def inspect
      "#<#{self.class} pattern=#{pattern.inspect} owners=#{owners.inspect} line_number=#{line_number}>"
    end
  end
end
