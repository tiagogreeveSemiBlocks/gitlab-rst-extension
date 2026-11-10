# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitlab::RstEnhanced do
  describe ".render" do
    it "converts basic RST to HTML" do
      expect(described_class.render("Hello *world*")).to include("<em>world</em>")
    end

    it "emits the wrapper class" do
      expect(described_class.render("test")).to include("rst-enhanced")
    end

    it "keeps admonition classes for styling" do
      rst = ".. warning::

   Be careful.
"
      expect(described_class.render(rst)).to include("admonition warning")
    end

    it "keeps table classes" do
      rst = "+----+----+
| A  | B  |
+====+====+
| 1  | 2  |
+----+----+
"
      expect(described_class.render(rst)).to include("<table")
    end

    it "neutralizes the raw directive" do
      rst = ".. raw:: html

   <script>alert(1)</script>
"
      expect(described_class.render(rst)).not_to include("<script>alert")
    end

    it "neutralizes the include directive" do
      rst = ".. include:: /etc/passwd
"
      expect(described_class.render(rst)).not_to include("root:")
    end
  end
end
