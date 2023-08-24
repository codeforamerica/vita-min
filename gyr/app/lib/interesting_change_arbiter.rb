class InterestingChangeArbiter
  IGNORED_KEYS = %w[
    canonical_email_address
    email_domain
    needs_to_flush_searchable_data_set_at
    updated_at
  ]

  def self.determine_changes(record)
    interesting_changes = record.saved_changes.select do |k, v|
      next if IGNORED_KEYS.include?(k)
      next if k.match?("hashed_")

      old_val, new_val = v
      next if %w[was_blind spouse_was_blind].include?(k) && old_val == "unfilled" && new_val == "no"

      true
    end

    interesting_changes.each_key do |k|
      if record.encrypted_attribute?(k)
        interesting_changes[k] = ["[REDACTED]", "[REDACTED]"]
      end
    end

    interesting_changes
  end
end
