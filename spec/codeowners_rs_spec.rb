# frozen_string_literal: true

RSpec.describe CodeownersRs do
  let(:fixture_path) { File.expand_path("fixtures/CODEOWNERS", __dir__) }
  let(:fixture_root) { File.dirname(fixture_path) }

  describe ".load" do
    it "returns a Ruleset" do
      codeowners = described_class.load(fixture_path, root: fixture_root)

      expect(codeowners).to be_a(described_class::Ruleset)
    end

    it "infers root from path when root is not provided" do
      codeowners = described_class.load(fixture_path)

      expect(codeowners.root).to eq(fixture_root)
    end
  end

  describe ".build" do
    it "returns a Ruleset" do
      codeowners = described_class.build(content: "content", root: fixture_root, path: fixture_path)

      expect(codeowners).to be_a(described_class::Ruleset)
    end
  end
end
