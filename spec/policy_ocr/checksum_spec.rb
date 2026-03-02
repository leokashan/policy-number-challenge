# frozen_string_literal: true

require_relative "../spec_helper"
require "policy_ocr/checksum"

RSpec.describe PolicyOcr::Checksum do
  describe ".valid?" do
    it "returns true for 000000000" do
      expect(described_class.valid?("000000000")).to be true
    end

    it "returns true for 123456789 (from challenge spec)" do
      expect(described_class.valid?("123456789")).to be true
    end

    it "returns true for 345882865 (from challenge PDF)" do
      expect(described_class.valid?("345882865")).to be true
    end

    it "returns true for 457508000 (from challenge PDF)" do
      expect(described_class.valid?("457508000")).to be true
    end

    it "returns false for 111111111" do
      expect(described_class.valid?("111111111")).to be false
    end

    it "returns false for 664371495 (from challenge PDF - ERR example)" do
      expect(described_class.valid?("664371495")).to be false
    end

    it "returns false for strings containing ?" do
      expect(described_class.valid?("12345678?")).to be false
      expect(described_class.valid?("?6110??36")).to be false
    end

    it "returns false for nil or invalid format" do
      expect(described_class.valid?(nil)).to be false
      expect(described_class.valid?("123")).to be false
      expect(described_class.valid?("12345678a")).to be false
    end
  end
end
