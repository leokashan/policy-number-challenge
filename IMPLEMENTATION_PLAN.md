# Kinsurance OCR — Implementation Plan (User Stories 1–3)

## Overview

Parse OCR-style policy numbers from a 4-line (3 data + 1 blank) format, validate them with a checksum, and write an output file with one policy number per line and status (`ERR` / `ILL`) when invalid or illegible.

**Tech:** Ruby, RSpec. **Goals:** High-level, efficient, well-organized code with tests, clear comments, and documentation.

---

## 1. User Story 1 — Parse OCR to Numbers

### Requirements
- Input: file with entries of **4 lines** each (3 lines of 27 chars + 1 blank).
- Each **digit** is a **3×3** grid of pipes `|` and underscores `_` (readable in code per challenge).
- Output: array of **9-digit strings** (or strings with `?` for illegible digits).

### Design

| Component | Responsibility |
|-----------|----------------|
| **Digit patterns** | Single source of truth: 3×3 string representation for digits 0–9 (readable format). |
| **Digit parser** | Map a 3-line × 3-char slice → digit `"0"`–`"9"` or `"?"` if unknown. |
| **Line splitter** | Split file into entries (chunks of 4 lines). |
| **Entry parser** | For each entry, take 9 columns (3 chars each), parse each column → one 9-char string. |

### Data structures
- **Digit grid:** 3 lines × 3 chars per digit. Store patterns as arrays of 3 strings, e.g. `[" _ ", "| |", "|_|"]` for `0`.
- **File:** split by `\n`, then each **4 lines** = one entry; ignore/skip blank line when grouping.

### Edge cases / assumptions
- Trailing newline after last entry is optional.
- Exactly 27 characters per data line; if not, treat as malformed (illegible or error).
- Illegible digit → output `?` for that position.

### File layout
- `lib/policy_ocr/digit_patterns.rb` — constant mapping 3×3 pattern → digit.
- `lib/policy_ocr/ocr_parser.rb` — parse one entry (27×3) → string of 9 digits/`?`.
- `lib/policy_ocr/file_parser.rb` — read file, split into entries, return array of 9-char strings.
- `lib/policy_ocr.rb` — facade: `PolicyOcr.parse_file(path)` → array of strings.

---

## 2. User Story 2 — Checksum Validation

### Requirements
- Valid policy number: `(d1 + 2*d2 + 3*d3 + … + 9*d9) mod 11 == 0`.
- **Position naming:** d9 = leftmost digit, d1 = rightmost (units). So index in string: position 0 → d9, position 8 → d1.

### Design
- **Single function:** `valid_checksum?(digit_string)`.
  - If string contains `?`, consider it invalid (cannot compute checksum).
  - Compute `sum = (1*d1 + 2*d2 + … + 9*d9)` using string indices: digit at index `i` has weight `(9 - i)`.
- **Module:** `lib/policy_ocr/checksum.rb` — `Checksum.valid?(digit_string)`.

### Formula (clarified)
- For string `s = "345882865"` (9 chars):  
  `d1 = s[8], d2 = s[7], …, d9 = s[0]`  
  `sum = 1*s[8] + 2*s[7] + … + 9*s[0]`  
  Valid iff `sum % 11 == 0`.

---

## 3. User Story 3 — Output File with Status

### Requirements
- One line per policy number.
- Format: `NNNNNNNNN` or `NNNNNNNNN ERR` or `NNN?NN?NN ILL`.
- **ERR:** valid format (no `?`) but checksum invalid.
- **ILL:** contains `?` (illegible).

### Design
- **Processor:** for each parsed policy string:
  - If contains `?` → status `ILL`.
  - Else if checksum invalid → status `ERR`.
  - Else → no status.
- **Output writer:** `lib/policy_ocr/output_writer.rb` — given array of (string, status), write lines to path.
- **Facade:** `PolicyOcr.process_file(input_path, output_path)`:
  1. Parse file → array of 9-char strings.
  2. For each string, compute status (`ILL` / `ERR` / nil).
  3. Write each line: `number` or `number status`.

### File format
- One policy number per line; optional second column separated by space: `ERR` or `ILL`.
- No trailing space when status is absent.

---

## 4. Code Style & Conventions (per challenge)

- **3×3 cells in code:** Define digits as readable 3-line strings, e.g.:
  ```ruby
  " " + "\n" + "|_|" + "\n" + " |"
  ```
  or as array of three strings per digit for clarity.
- **Comments:** Document checksum index convention (d9…d1), and any assumptions (e.g. 27 chars, 4-line entries).
- **Error handling:** Malformed lines (wrong length) → treat whole entry or digit as illegible (`?` / ILL) rather than raising, so one bad entry doesn’t stop the file.

---

## 5. Test Plan

| Story | What to test |
|-------|----------------|
| **1** | Digit patterns: each known digit 0–9 parses correctly; one unknown pattern → `?`. Entry parser: given 3 lines of 27 chars, get correct 9-char string. File parser: sample file → correct number of entries and known sequences (e.g. 000000000, 111111111). |
| **2** | Valid numbers (e.g. 345882865 from spec) → valid. Invalid sum → invalid. String with `?` → invalid. |
| **3** | Output file: lines for valid, ERR, ILL; format exact (no status vs ` ERR` / ` ILL`). |

### Fixtures
- Reuse `spec/fixtures/sample.txt` for integration.
- Add small fixtures: one entry only (e.g. 000000000), one with `?`, one ERR, for fast unit tests.

---

## 6. Implementation Order

1. **Digit patterns + OCR parser** — implement 3×3 patterns, parse one digit, then one entry, then file. Unit tests for digit and entry; integration for file.
2. **Checksum** — implement formula, unit tests with known valid/invalid.
3. **Output writer + processor** — status logic and file write; test output content and format.
4. **Facade + README** — `PolicyOcr.parse_file`, `PolicyOcr.process_file`, plus README with run instructions and system deps (e.g. Ruby 3.x).

---

## 7. File Layout Summary

```
lib/
  policy_ocr.rb                 # Facade
  policy_ocr/
    digit_patterns.rb           # 3×3 → "0"…”9”
    ocr_parser.rb               # entry (3 lines) → "NNN..."
    file_parser.rb              # file → entries
    checksum.rb                 # valid?(digit_string)
    output_writer.rb            # write output file
spec/
  policy_ocr_spec.rb            # integration
  policy_ocr/
    digit_patterns_spec.rb
    ocr_parser_spec.rb
    file_parser_spec.rb
    checksum_spec.rb
    output_writer_spec.rb
spec/fixtures/
  sample.txt                    # existing
  single_entry_zeros.txt        # one entry 000000000
  one_illegible.txt             # one entry with ? 
  one_err.txt                   # one entry wrong checksum
```

---

## 8. Acceptance Criteria (Summary)

- [ ] **US1:** Parse input file → array of 9-char strings (digits or `?`).
- [ ] **US2:** `valid_checksum?(s)` correct for valid/invalid and `?`.
- [ ] **US3:** Output file: one line per policy; `ERR` / `ILL` in second column when applicable.
- [ ] 3×3 digits represented in readable form in code.
- [ ] Meaningful unit + integration tests; clear comments and README with run instructions.
