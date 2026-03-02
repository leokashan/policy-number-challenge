# frozen_string_literal: true

require_relative "ocr_parser"

module PolicyOcr
  # Splits an OCR file into 4-line entries and parses each into a policy number string.
  # Format: 3 data lines (27 chars each) + 1 blank line per entry.
  module FileParser
    LINES_PER_ENTRY = 4
    DATA_LINES_PER_ENTRY = 3

    # @param file_path [String] path to input file
    # @return [Array<String>] array of 9-character policy number strings
    def self.parse_file(file_path)
      raise ArgumentError, "File not found: #{file_path}" unless File.exist?(file_path)

      content = File.read(file_path, encoding: "UTF-8")
      entries = split_into_entries(content)
      entries.map { |entry_lines| OcrParser.parse_entry(entry_lines) }
    end

    # Splits raw file content into arrays of 3 data lines per entry.
    # Each entry is 4 lines: 3 data lines + 1 blank line.
    def self.split_into_entries(content)
      content.split("\n").each_slice(LINES_PER_ENTRY).map do |chunk|
        chunk[0, DATA_LINES_PER_ENTRY] if chunk.size >= DATA_LINES_PER_ENTRY
      end.compact
    end
    private_class_method :split_into_entries
  end
end
