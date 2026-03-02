#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Parse and process the sample OCR file.
# Run from project root: ruby examples/run_sample.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "policy_ocr"

input_path = File.join(__dir__, "..", "spec", "fixtures", "sample.txt")
output_path = File.join(__dir__, "..", "output.txt")

PolicyOcr.process_file(input_path, output_path)

puts "Parsed #{File.basename(input_path)}"
puts "Output written to #{output_path}"
puts
puts "--- Output ---"
puts File.read(output_path)
