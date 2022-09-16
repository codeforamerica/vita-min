class InterestingChangeArbiter
  IGNORED_KEYS = %w[
    canonical_email_address
    email_domain
    needs_to_flush_searchable_data_set_at
    updated_at
  ]

  def self.determine_changes(model)
    interesting_changes = model.saved_changes.select do |k, v|
      next if IGNORED_KEYS.include?(k)
      next if k.match?("hashed_")
      next if ["was_blind", "spouse_was_blind"].include?(k) && v == ["unfilled", "no"]

      true
    end

    interesting_changes.each_key do |k|
      if model.encrypted_attribute?(k)
        interesting_changes[k] = ["[REDACTED]", "[REDACTED]"]
      end
    end

    interesting_changes
  end
end
