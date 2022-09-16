class InterestingChangeArbiter
  IGNORED_KEYS = %w[
    canonical_email_address
    email_domain
    needs_to_flush_searchable_data_set_at
    updated_at
  ]

  def self.determine_changes(model, new)
    changes = new ? model.attributes.map { |k, v| [k, [nil, v]] }.to_h : model.saved_changes
    interesting_changes = changes.reject do |k, v|
      IGNORED_KEYS.include?(k) ||
        k.match?("hashed_") ||
        v == ["unfilled", "no"] && ["was_blind", "spouse_was_blind"].include?(k) ||
        (new && (k == "created_at" || k == "creation_token")) ||
        (new && v.nil?)
    end

    interesting_changes.each_key do |k|
      if model.encrypted_attribute?(k)
        interesting_changes[k] = ["[REDACTED]", "[REDACTED]"]
      end
    end

    interesting_changes
  end
end
