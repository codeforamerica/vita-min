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
class SystemNote::StatusChange < SystemNote
  def self.generate!(tax_return:, initiated_by: nil, old_status: nil, new_status: nil)
    unless old_status && new_status
      old_status, new_status = tax_return.saved_change_to_status
    end

    old_status_with_stage = TaxReturnStatusHelper.stage_and_status_translation(old_status)
    new_status_with_stage = TaxReturnStatusHelper.stage_and_status_translation(new_status)
    initiated_by_message = initiated_by.present? ? "#{initiated_by.name} updated" : "Automated update of"

    create!(
      body: "#{initiated_by_message} #{tax_return.year} tax return status from #{old_status_with_stage} to #{new_status_with_stage}",
      client: tax_return.client,
      user: initiated_by
    )
  end
end
