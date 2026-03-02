# frozen_string_literal: true

require "tempfile"
require_relative "../spec_helper"
require "policy_ocr/file_parser"

RSpec.describe PolicyOcr::FileParser do
  describe ".parse_file" do
    it "parses sample.txt with 11 entries" do
      result = described_class.parse_file(fixture_path("sample"))
      expect(result.size).to eq(11)
    end

    it "parses sample.txt with correct known sequences" do
      result = described_class.parse_file(fixture_path("sample"))
      expect(result[0]).to eq("000000000")
      expect(result[1]).to eq("111111111")
      expect(result[2]).to eq("222222222")
      expect(result[9]).to eq("999999999")
      expect(result[10]).to eq("123456789")
    end

    it "parses single_entry_zeros" do
      result = described_class.parse_file(fixture_path("single_entry_zeros"))
      expect(result).to eq(["000000000"])
    end

    it "parses valid_checksum fixture" do
      result = described_class.parse_file(fixture_path("valid_checksum"))
      expect(result).to eq(["123456789"])
    end

    it "parses one_illegible fixture" do
      result = described_class.parse_file(fixture_path("one_illegible"))
      expect(result).to eq(["12345678?"])
    end

    it "parses invalid_checksum fixture" do
      result = described_class.parse_file(fixture_path("invalid_checksum"))
      expect(result).to eq(["111111111"])
    end

    it "raises ArgumentError when file does not exist" do
      expect { described_class.parse_file("/nonexistent/path.txt") }
        .to raise_error(ArgumentError, /File not found/)
    end

    it "parses valid_and_invalid fixture with 10 valid and 10 invalid policy numbers" do
      result = described_class.parse_file(fixture_path("valid_and_invalid"))
      expect(result.size).to eq(20)

      valid_numbers = %w[
        000000000 123456789 345882865 457508000 111111110
        222222220 000000019 000000078 000000086 000000108
      ]
      invalid_numbers = %w[
        111111111 222222222 555555555 999999999 000000001
        000000010 123456788 664371495 000000011 888888888
      ]

      expect(result[0, 10]).to eq(valid_numbers)
      expect(result[10, 10]).to eq(invalid_numbers)
    end

    it "strips UTF-8 BOM from file start" do
      content = "\uFEFF" + fixture("single_entry_zeros")
      tmp = Tempfile.new(["bom", ".txt"])
      tmp.write(content)
      tmp.close
      result = described_class.parse_file(tmp.path)
      expect(result).to eq(["000000000"])
      tmp.unlink
    end

    it "handles Windows line endings (\\r\\n)" do
      content = fixture("single_entry_zeros").gsub("\n", "\r\n")
      tmp = Tempfile.new(["crlf", ".txt"])
      tmp.write(content)
      tmp.close
      result = described_class.parse_file(tmp.path)
      expect(result).to eq(["000000000"])
      tmp.unlink
    end

    it "skips phantom entries from trailing blank lines" do
      content = fixture("single_entry_zeros") + "\n\n\n\n"
      tmp = Tempfile.new(["trailing", ".txt"])
      tmp.write(content)
      tmp.close
      result = described_class.parse_file(tmp.path)
      expect(result).to eq(["000000000"])
      tmp.unlink
    end
  end
end
