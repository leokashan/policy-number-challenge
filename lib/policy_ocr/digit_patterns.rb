# frozen_string_literal: true

module PolicyOcr
  # Maps 3×3 OCR digit patterns (readable format per challenge) to digit characters.
  # Each digit is represented as 3 lines of 3 characters; patterns use pipes | and underscores _.
  module DigitPatterns
    # Digit patterns as arrays of 3 strings (one per row). Format: [row0, row1, row2]
    # where each row is exactly 3 characters wide.
    PATTERNS = {
      # 0: top, both sides, bottom
      [" _ ", "| |", "|_|"] => "0",
      # 1: right side only
      ["   ", "  |", "  |"] => "1",
      # 2: top, top-right, bottom-left
      [" _ ", " _|", "|_ "] => "2",
      # 3: top, top-right, top-right
      [" _ ", " _|", " _|"] => "3",
      # 4: middle bar, right side
      ["   ", "|_|", "  |"] => "4",
      # 5: top, bottom-left, top-right
      [" _ ", "|_ ", " _|"] => "5",
      # 6: top, bottom-left, bottom
      [" _ ", "|_ ", "|_|"] => "6",
      # 7: top, right side
      [" _ ", "  |", "  |"] => "7",
      # 8: top, both sides, bottom
      [" _ ", "|_|", "|_|"] => "8",
      # 9: top, both sides, top-right
      [" _ ", "|_|", " _|"] => "9"
    }.freeze

    # Reverse mapping: digit character -> pattern (for reference/debugging)
    DIGIT_TO_PATTERN = PATTERNS.invert.freeze

    # Returns digit "0"-"9" for a known pattern, or "?" if illegible.
    # @param rows [Array<String>] 3 strings of length 3 each
    # @return [String] single character
    def self.parse(rows)
      return "?" if rows&.size != 3 || rows.any? { |r| !r.is_a?(String) || r.length != 3 }

      key = rows.map { |r| r.ljust(3)[0, 3] }
      PATTERNS[key] || "?"
    end
  end
end
