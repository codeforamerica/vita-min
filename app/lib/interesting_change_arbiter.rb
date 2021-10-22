class InterestingChangeArbiter
  def self.determine_changes(original_model, model)
    interesting_changes = model.saved_changes.reject do |k, v|
      k == "updated_at" ||
        k == "needs_to_flush_searchable_data_set_at" ||
        k.match?("hashed_") ||
        encrypted_columns(model).include?(k)
    end

    # attr_encrypted fields do not correctly report whether they have changed in
    # saved_changes; the `encrypted_` fields always look like they have changed,
    # and the old values of the decrypted accessor methods (`ssn_was`, etc)
    # is always nil, possibly because of this issue:
    # https://github.com/attr-encrypted/attr_encrypted/pull/337
    # To work around this, we keep the original model and compare any attr_encrypted
    # fields manually
    if encrypted_columns(model).present?
      encrypted_column_accessors(model).each do |encrypted_column_accessor|
        if original_model.send(encrypted_column_accessor) != model.send(encrypted_column_accessor)
          interesting_changes[encrypted_column_accessor.to_s] = ["[REDACTED]", "[REDACTED]"]
        else
          interesting_changes.delete(encrypted_column_accessor.to_s)
        end
      end
    end

    interesting_changes
  end

  def self.encrypted_column_accessors(model)
    encrypted_columns(model).reject { |column| column.ends_with?('_iv') }.map { |column| column.sub(/^encrypted_/, '').to_sym }
  end
  private_class_method :encrypted_column_accessors

  def self.encrypted_columns(model)
    model.saved_changes.keys.select { |k| k.start_with?("encrypted_") }
  end
  private_class_method :encrypted_columns
end
