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
  def self.generate!(model:, client:)
    interesting_changes = InterestingChangeArbiter.determine_changes(model)
    return unless interesting_changes.present?

    create!(
      data: {
        model: model.to_global_id.to_s,
        changes: interesting_changes
      },
      client: client
    )
  end
end
