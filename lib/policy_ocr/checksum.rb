# frozen_string_literal: true

module PolicyOcr
  # Validates policy numbers using checksum: (d1 + 2*d2 + ... + 9*d9) mod 11 == 0
  # Position naming: d9 = leftmost (index 0), d1 = rightmost (index 8).
  # Strings containing "?" are considered invalid (cannot compute checksum).
  module Checksum
    CHECKSUM_MOD = 11

    # @param digit_string [String] 9-character string of digits (no "?")
    # @return [Boolean] true if checksum valid
    def self.valid?(digit_string)
      return false if digit_string.nil? || digit_string.include?("?")
      return false unless digit_string.length == 9
      return false unless digit_string.match?(/\A\d{9}\z/)

      sum = digit_string.each_char.with_index.sum { |char, i| (9 - i) * char.to_i }
      (sum % CHECKSUM_MOD).zero?
    end
  end
end
