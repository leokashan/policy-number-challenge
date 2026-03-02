# frozen_string_literal: true

require_relative "checksum"

module PolicyOcr
  # Writes parsed policy numbers to an output file with status (ERR/ILL) when applicable.
  # Format: one line per policy; "NNNNNNNNN" or "NNNNNNNNN ERR" or "NNN?NN?NN ILL".
  module OutputWriter
    STATUS_ILL = "ILL"
    STATUS_ERR = "ERR"

    # @param policy_numbers [Array<String>] parsed 9-char strings
    # @param output_path [String] path to write
    def self.write(policy_numbers, output_path)
      lines = policy_numbers.map { |num| status_for(num).then { |s| s ? "#{num} #{s}" : num } }
      File.write(output_path, lines.join("\n") + "\n")
    end

    # Determines status for a single policy number.
    # ILL = contains "?" (illegible); ERR = valid format but bad checksum.
    def self.status_for(policy_number)
      return STATUS_ILL if policy_number.include?("?")
      return STATUS_ERR unless Checksum.valid?(policy_number)

      nil
    end
  end
end
