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
class SystemNote::ClientChange < SystemNote
  def self.generate!(intake:, initiated_by: )
    return unless intake.saved_changes.present?

    changes_list = ""
    intake.saved_changes.each do |k, v|
      next if k == "updated_at"
      next if k == "needs_to_flush_searchable_data_set_at"
      next if k.include?("encrypted")

      changes_list += "\n\u2022 #{k.tr('_', ' ')} from #{v[0]} to #{v[1]}"
    end
    if changes_list.present?
      create!(
        body: "#{initiated_by.name} changed: #{changes_list}",
        client: intake.client,
        user: initiated_by
      )
    end
  end
end
