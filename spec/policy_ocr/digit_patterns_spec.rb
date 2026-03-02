# frozen_string_literal: true

require_relative "../spec_helper"
require "policy_ocr/digit_patterns"

RSpec.describe PolicyOcr::DigitPatterns do
  describe ".parse" do
    (0..9).each do |digit|
      it "parses digit #{digit} correctly" do
        pattern = described_class::DIGIT_TO_PATTERN[digit.to_s]
        expect(described_class.parse(pattern)).to eq(digit.to_s)
      end
    end

    it "returns ? for unknown pattern" do
      unknown = ["|_|", "|_|", "|_|"]
      expect(described_class.parse(unknown)).to eq("?")
    end

    it "returns ? for nil rows" do
      expect(described_class.parse(nil)).to eq("?")
    end

    it "returns ? for wrong number of rows" do
      expect(described_class.parse([" _ ", "| |"])).to eq("?")
    end
  end
end
