# Kinsurance OCR — Policy Number Parser

Parses OCR-style policy numbers from scanned documents, validates them with a checksum, and writes output with status (`ERR` / `ILL`) for invalid or illegible numbers.

## System Requirements

- **Ruby** 2.6+ (tested with Ruby 3.3.7)
- **Bundler** (for running tests)

## Installation

```bash
bundle install
```

## Running the Example

Process an OCR file and write results to `output.txt`:

```bash
ruby bin/process spec/fixtures/sample.txt output.txt
```

This parses the input, writes to the output file, and prints the contents to the terminal.

## Running Tests

```bash
bundle exec rspec
```

## API

### `PolicyOcr.parse_file(file_path)`

Parses an OCR file and returns an array of 9-character policy number strings (digits or `?` for illegible).

```ruby
require "policy_ocr"
PolicyOcr.parse_file("spec/fixtures/sample.txt")
# => ["000000000", "111111111", "222222222", ...]
```

Raises `ArgumentError` if the file does not exist.

### `PolicyOcr.process_file(input_path, output_path)`

Parses the input file, validates each number, and writes output with status:

- **Valid:** `NNNNNNNNN` (no suffix)
- **Invalid checksum:** `NNNNNNNNN ERR`
- **Illegible:** `NNN?NN?NN ILL`

## Input Format

Each entry is 4 lines: 3 data lines (27 characters each) + 1 blank line. Digits are 3×3 grids of pipes (`|`) and underscores (`_`).

## Checksum

Valid policy numbers satisfy: `(d1 + 2*d2 + ... + 9*d9) mod 11 == 0`, where `d1` is the rightmost digit and `d9` is the leftmost.

## Project Structure

```
lib/
  policy_ocr.rb           # Main facade
  policy_ocr/
    digit_patterns.rb     # 3×3 digit patterns
    ocr_parser.rb         # Parses OCR entry → string
    file_parser.rb        # Splits file into entries
    checksum.rb           # Validates checksum
    output_writer.rb      # Writes output file
bin/
  process                 # CLI: ruby bin/process input.txt output.txt
spec/
  policy_ocr_spec.rb      # Integration tests
  policy_ocr/             # Unit specs
  fixtures/               # Sample OCR files
```
