# frozen_string_literal: true

RSpec.describe CodeownersRs::Rule do
  describe ".from_line" do
    it "parses pattern and teams" do
      line = "/docs/ @team-1 @team-2 @team-3"
      rule = described_class.from_line(line, 1)

      expect(rule.pattern).to eq("/docs/")
      expect(rule.owners).to eq(["@team-1", "@team-2", "@team-3"])
    end

    it "handles comments" do
      line = "/docs/ @team-1 @team-2 # comment"
      rule = described_class.from_line(line, 1)

      expect(rule.pattern).to eq("/docs/")
      expect(rule.owners).to eq(["@team-1", "@team-2"])
    end
  end
end
