# frozen_string_literal: true

require_relative "policy_ocr/file_parser"
require_relative "policy_ocr/output_writer"

module PolicyOcr
  # Main facade for the Kinsurance OCR policy number parser.
  #
  # Usage:
  #   PolicyOcr.parse_file("input.txt")        # => ["000000000", "111111111", ...]
  #   PolicyOcr.process_file("input.txt", "output.txt")
  #

  # Parses an OCR file and returns an array of 9-character policy number strings.
  # @param file_path [String]
  # @return [Array<String>]
  def self.parse_file(file_path)
    FileParser.parse_file(file_path)
  end

  # Parses an OCR file, validates each number, and writes output with status (ERR/ILL).
  # @param input_path [String]
  # @param output_path [String]
  def self.process_file(input_path, output_path)
    policy_numbers = parse_file(input_path)
    OutputWriter.write(policy_numbers, output_path)
  end
end
