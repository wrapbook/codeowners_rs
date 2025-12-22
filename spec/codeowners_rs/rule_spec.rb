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

  describe "#match?" do
    def rule(pattern)
      described_class.new(pattern, ["@owner"], 1)
    end

    it "matches *" do
      rule = rule("*")
      expect(rule).to match_path("/test")
    end

    it "matches * with extension" do
      rule = rule("*.js")
      expect(rule).to match_path("test.js")
      expect(rule).not_to match_path("test.ts")
    end

    it "matches directory starting at root" do
      rule = rule("/build/logs/")
      expect(rule).to match_path("/build/logs/test.log")
      expect(rule).not_to match_path("/dev/build/logs/test.log")
    end

    it "matches rootless directory" do
      rule = rule("docs/")
      expect(rule).to match_path("/app/docs/setup/info.md")
    end

    it "matches directory with *" do
      rule = rule("docs/*")
      expect(rule).to match_path("docs/getting-started.md")
      expect(rule).not_to match_path("docs/build-app/troubleshooting.md")
    end

    it "matches /**" do
      rule = rule("/docs/**")
      expect(rule).to match_path("/docs/setup/dev/getting-started.md")
    end

    it "matches /**/dir" do
      rule = rule("/**/docs")

      expect(rule).to match_path("/app/docs/setup/info.md")
      expect(rule).to match_path("/src/app/docs/setup/info.md")
    end

    it "matches /**/*word*" do
      rule = rule("/**/*doc*")

      expect(rule).to match_path("/app/docs/setup/info.md")
      expect(rule).to match_path("/src/app/docs/setup/info.md")
    end

    it "escapes ." do
      rule = rule("file.ex")

      expect(rule).to match_path("file.ex")
      expect(rule).not_to match_path("fileaex")
    end
  end
end
