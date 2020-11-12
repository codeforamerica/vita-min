# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
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
class SystemNote < ApplicationRecord
  belongs_to :client
  belongs_to :user, required: false

  validates_presence_of :body

  def self.create_status_change_note(user, tax_return)
    old_status, new_status = tax_return.saved_change_to_status

    old_status_with_stage = TaxReturnStatusHelper::stage_and_status_translation(old_status)
    new_status_with_stage = TaxReturnStatusHelper::stage_and_status_translation(new_status)

    SystemNote.create(
        body: "#{user.name} updated #{tax_return.year} tax return status from #{old_status_with_stage} to #{new_status_with_stage}",
        client: tax_return.client,
        user: user
    )
  end
end
