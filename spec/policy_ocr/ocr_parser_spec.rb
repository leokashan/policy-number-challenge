# frozen_string_literal: true

require_relative "../spec_helper"
require "policy_ocr/ocr_parser"

RSpec.describe PolicyOcr::OcrParser do
  describe ".parse_entry" do
    it "parses 000000000 from 3 lines" do
      lines = fixture("single_entry_zeros").split("\n")[0, 3]
      expect(described_class.parse_entry(lines)).to eq("000000000")
    end

    it "parses 111111111" do
      lines = [
        "                           ",
        "  |  |  |  |  |  |  |  |  |",
        "  |  |  |  |  |  |  |  |  |"
      ]
      expect(described_class.parse_entry(lines)).to eq("111111111")
    end

    it "parses 123456789" do
      lines = fixture("valid_checksum").split("\n")[0, 3]
      expect(described_class.parse_entry(lines)).to eq("123456789")
    end

    it "returns ? for illegible digits" do
      lines = fixture("one_illegible").split("\n")[0, 3]
      expect(described_class.parse_entry(lines)).to eq("12345678?")
    end

    it "returns ???????? for nil input" do
      expect(described_class.parse_entry(nil)).to eq("?????????")
    end
  end
end
