# frozen_string_literal: true

RSpec.describe CodeownersRs::Ruleset do
  let(:fixture_path) { File.expand_path("../fixtures/CODEOWNERS", __dir__) }
  let(:fixture_root) { File.dirname(fixture_path) }

  describe ".load" do
    it "loads a CODEOWNERS file" do
      codeowners = described_class.load(fixture_path, fixture_root)

      expect(codeowners).to be_a(described_class)
      expect(codeowners.path).to eq(fixture_path)
      expect(codeowners.rules).not_to be_empty
    end

    it "sets the root directory" do
      codeowners = described_class.load(fixture_path, "/custom/root")

      expect(codeowners.root).to eq("/custom/root")
    end

    it "defaults root to parent directory of CODEOWNERS file" do
      codeowners = described_class.load(fixture_path, fixture_root)

      expect(codeowners.root).to eq(fixture_root)
    end

    it "trims trailing slash from root" do
      codeowners = described_class.load(fixture_path, "/custom/root/")

      expect(codeowners.root).to eq("/custom/root")
    end
  end

  describe ".build" do
    let(:content) do
      <<~CODEOWNERS
        # Comment
        * @global

        *.md @docs
        /build/ @build-team
      CODEOWNERS
    end

    it "builds from content string" do
      codeowners = described_class.build(content, "/root", "path/to/CODEOWNERS")

      expect(codeowners.rules.length).to eq(3)
      expect(codeowners.root).to eq("/root")
      expect(codeowners.path).to eq("path/to/CODEOWNERS")
    end

    it "ignores blank lines" do
      content_with_blanks = "* @owner\n\n\n*.md @docs"
      codeowners = described_class.build(content_with_blanks, "/root", nil)

      expect(codeowners.rules.length).to eq(2)
    end

    it "ignores comment lines" do
      content_with_comments = "# Comment\n* @owner\n# Another comment"
      codeowners = described_class.build(content_with_comments, "/root", nil)

      expect(codeowners.rules.length).to eq(1)
    end
  end

  describe "#rule_for_path" do
    let(:codeowners) { described_class.load(fixture_path, fixture_root) }

    it "finds matching rule for path" do
      rule = codeowners.rule_for_path("#{fixture_root}/README.txt")

      expect(rule.pattern).to eq("*.txt")
      expect(rule.owners).to eq(["@octo-org/octocats"])
    end

    it "returns last matching rule when multiple patterns match" do
      rule = codeowners.rule_for_path("#{fixture_root}/docs/setup.txt")

      # Both *.txt and /docs/ match, but /docs/ is more specific and comes later
      expect(rule.pattern).to eq("/docs/")
      expect(rule.owners).to eq(["@doctocat"])
    end

    it "strips root path when matching" do
      rule = codeowners.rule_for_path("#{fixture_root}/test.js")

      expect(rule.pattern).to eq("*.js")
      expect(rule.owners).to eq(["@js-owner"])
    end

    it "handles paths without leading slash" do
      rule = codeowners.rule_for_path("docs/setup.md")

      expect(rule.pattern).to eq("/docs/")
    end

    it "returns nil when no match found" do
      codeowners = described_class.build("", "/", nil)
      rule = codeowners.rule_for_path("#{fixture_root}/unknown.xyz")

      expect(rule).to be_nil
    end

    describe "patterns" do
      def ruleset(pattern)
        described_class.build("#{pattern} @owner", "/", nil)
      end

      it "matches *" do
        rule = ruleset("*")
        expect(rule).to match_path("/test")
      end

      it "matches * with extension" do
        rule = ruleset("*.js")
        expect(rule).to match_path("test.js")
        expect(rule).not_to match_path("test.ts")
      end

      it "matches directory starting at root" do
        rule = ruleset("/build/logs/")
        expect(rule).to match_path("/build/logs/test.log")
        expect(rule).not_to match_path("/dev/build/logs/test.log")
      end

      it "matches rootless directory" do
        rule = ruleset("docs/")
        expect(rule).to match_path("/app/docs/setup/info.md")
      end

      it "matches directory with *" do
        rule = ruleset("docs/*")
        expect(rule).to match_path("docs/getting-started.md")
        expect(rule).not_to match_path("docs/build-app/troubleshooting.md")
      end

      it "matches /**" do
        rule = ruleset("/docs/**")
        expect(rule).to match_path("/docs/setup/dev/getting-started.md")
      end

      it "matches /**/dir" do
        rule = ruleset("/**/docs")

        expect(rule).to match_path("/app/docs/setup/info.md")
        expect(rule).to match_path("/src/app/docs/setup/info.md")
      end

      it "matches /**/*word*" do
        rule = ruleset("/**/*doc*")

        expect(rule).to match_path("/app/docs/setup/info.md")
        expect(rule).to match_path("/src/app/docs/setup/info.md")
      end

      it "escapes ." do
        rule = ruleset("file.ex")

        expect(rule).to match_path("file.ex")
        expect(rule).not_to match_path("fileaex")
      end
    end
  end

  describe "#owners_for_path" do
    let(:codeowners) { described_class.load(fixture_path, fixture_root) }

    it "returns owners for matching path" do
      owners = codeowners.owners_for_path("#{fixture_root}/README.txt")
      expect(owners).to eq(["@octo-org/octocats"])
    end
  end

  describe "#owners_for_constant" do
    let(:codeowners) { described_class.build("* @ruby-team", "/", nil) }

    it "returns owners for constant's source file" do
      owners = codeowners.owners_for_constant(described_class)
      expect(owners).to eq(["@ruby-team"])
    end

    it "returns empty array for unknown constant" do
      owners = codeowners.owners_for_constant("NonExistent::Constant")
      expect(owners).to be_empty
    end
  end

  describe "#rules" do
    let(:codeowners) { described_class.load(fixture_path, fixture_root) }

    it "returns array of rules" do
      rules = codeowners.rules

      expect(rules).to be_an(Array)
      expect(rules.first).to be_a(CodeownersRs::Rule)
    end

    it "preserves line numbers" do
      rules = codeowners.rules

      # First non-comment, non-blank line is line 10: "* @global-owner1 @global-owner2"
      expect(rules.first.line_number).to eq(10)
    end
  end
end
