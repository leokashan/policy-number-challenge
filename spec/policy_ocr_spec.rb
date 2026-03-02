# frozen_string_literal: true

require "tempfile"
require_relative "spec_helper"
require "policy_ocr"

describe PolicyOcr do
  it "loads" do
    expect(PolicyOcr).to be_a Module
  end

  it "loads the sample.txt" do
    expect(fixture("sample").lines.count).to eq(44)
  end

  describe "integration with sample fixtures" do
    it "parses sample.txt into 11 policy numbers" do
      result = PolicyOcr.parse_file(fixture_path("sample"))
      expect(result.size).to eq(11)
      expect(result).to eq(
        %w[
          000000000
          111111111
          222222222
          333333333
          444444444
          555555555
          666666666
          777777777
          888888888
          999999999
          123456789
        ]
      )
    end

    it "process_file writes correct output for sample.txt" do
      tmp = Tempfile.new(["policy_ocr_sample", ".txt"])
      PolicyOcr.process_file(fixture_path("sample"), tmp.path)

      content = File.read(tmp.path)
      lines = content.strip.split("\n")

      expect(lines.size).to eq(11)
      expect(lines[0]).to eq("000000000")
      expect(lines[1]).to eq("111111111 ERR")
      expect(lines[10]).to eq("123456789")

      tmp.close
      tmp.unlink
    end

    it "process_file writes ILL for illegible and ERR for bad checksum" do
      tmp = Tempfile.new(["policy_ocr_mixed", ".txt"])
      output_path = tmp.path
      PolicyOcr.process_file(fixture_path("one_illegible"), output_path)
      expect(File.read(output_path).strip).to eq("12345678? ILL")

      PolicyOcr.process_file(fixture_path("invalid_checksum"), output_path)
      expect(File.read(output_path).strip).to eq("111111111 ERR")

      tmp.close
      tmp.unlink
    end

    it "process_file writes correct output for valid_and_invalid (10 valid, 10 ERR)" do
      tmp = Tempfile.new(["policy_ocr_valid_invalid", ".txt"])
      output_path = tmp.path
      PolicyOcr.process_file(fixture_path("valid_and_invalid"), output_path)

      lines = File.read(output_path).strip.split("\n")
      expect(lines.size).to eq(20)

      # First 10 valid: no status (just the number)
      valid_lines = lines[0, 10]
      valid_lines.each do |line|
        expect(line).not_to include(" ERR")
        expect(line).not_to include(" ILL")
      end

      # Last 10 invalid: ERR status
      invalid_lines = lines[10, 10]
      invalid_lines.each do |line|
        expect(line).to end_with(" ERR")
      end

      tmp.close
      tmp.unlink
    end
  end
end
