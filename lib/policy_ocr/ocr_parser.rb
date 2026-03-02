# frozen_string_literal: true

require_relative "digit_patterns"

module PolicyOcr
  # Parses a single OCR entry (3 lines × 27 chars) into a 9-character policy number string.
  # Each digit occupies 3 columns; unknown patterns become "?".
  module OcrParser
    DIGITS_PER_LINE = 9
    CHARS_PER_DIGIT = 3
    EXPECTED_LINE_LENGTH = DIGITS_PER_LINE * CHARS_PER_DIGIT # 27

    # @param lines [Array<String>] exactly 3 lines, each 27 characters (longer lines truncated)
    # @return [String] 9-character string of digits and/or "?"
    def self.parse_entry(lines)
      return "?" * DIGITS_PER_LINE if lines.nil? || lines.size != 3
      return "?" * DIGITS_PER_LINE if lines.any? { |l| l.nil? || l.length < EXPECTED_LINE_LENGTH }

      lines = lines.map { |l| l[0, EXPECTED_LINE_LENGTH] }
      (0...DIGITS_PER_LINE).map do |i|
        col_start = i * CHARS_PER_DIGIT
        rows = lines.map { |line| extract_slice(line, col_start) }
        DigitPatterns.parse(rows)
      end.join
    end

    def self.extract_slice(line, start)
      return "   " if line.nil? || line.length < start + CHARS_PER_DIGIT

      line[start, CHARS_PER_DIGIT].ljust(CHARS_PER_DIGIT)
    end
    private_class_method :extract_slice
  end
end
