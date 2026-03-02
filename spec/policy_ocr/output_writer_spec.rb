# frozen_string_literal: true

require "tempfile"
require_relative "../spec_helper"
require "policy_ocr/output_writer"

RSpec.describe PolicyOcr::OutputWriter do
  describe ".write" do
    it "writes valid numbers without status" do
      tmp = Tempfile.new(["output", ".txt"])
      described_class.write(["000000000", "123456789"], tmp.path)
      content = File.read(tmp.path)
      expect(content).to eq("000000000\n123456789\n")
      tmp.close
      tmp.unlink
    end

    it "writes ERR for invalid checksum" do
      tmp = Tempfile.new(["output", ".txt"])
      described_class.write(["111111111"], tmp.path)
      content = File.read(tmp.path)
      expect(content).to eq("111111111 ERR\n")
      tmp.close
      tmp.unlink
    end

    it "writes ILL for illegible numbers" do
      tmp = Tempfile.new(["output", ".txt"])
      described_class.write(["12345678?"], tmp.path)
      content = File.read(tmp.path)
      expect(content).to eq("12345678? ILL\n")
      tmp.close
      tmp.unlink
    end

    it "writes mixed statuses correctly" do
      tmp = Tempfile.new(["output", ".txt"])
      described_class.write(["457508000", "664371495", "86110??36"], tmp.path)
      content = File.read(tmp.path)
      expect(content).to eq("457508000\n664371495 ERR\n86110??36 ILL\n")
      tmp.close
      tmp.unlink
    end
  end

  describe ".status_for" do
    it "returns nil for valid numbers" do
      expect(described_class.status_for("000000000")).to be_nil
      expect(described_class.status_for("123456789")).to be_nil
    end

    it "returns ERR for invalid checksum" do
      expect(described_class.status_for("111111111")).to eq("ERR")
    end

    it "returns ILL for illegible numbers" do
      expect(described_class.status_for("12345678?")).to eq("ILL")
    end
  end
end
