# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
#  data       :jsonb
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#  user_id    :bigint
#
# Indexes
#
#  index_system_notes_on_client_id  (client_id)
#  index_system_notes_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
class SystemNote::CtcPortalUpdate < SystemNote
  def self.generate!(original_model:, model:, client:)
    interesting_changes = model.saved_changes.reject do |k, v|
      k == "updated_at" ||
        k == "needs_to_flush_searchable_data_set_at" ||
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

    return unless interesting_changes.present?

    create!(
      data: {
        model: model.to_global_id.to_s,
        changes: interesting_changes
      },
      client: client
    )
  end

  private

  def self.encrypted_column_accessors(model)
    encrypted_columns(model).reject { |column| column.ends_with?('_iv') }.map { |column| column.sub(/^encrypted_/, '').to_sym }
  end

  def self.encrypted_columns(model)
    model.saved_changes.keys.select { |k| k.start_with?("encrypted_") }
  end
end
