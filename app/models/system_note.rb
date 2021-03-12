# == Schema Information
#
# Table name: system_notes
#
#  id         :bigint           not null, primary key
#  body       :text
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
class SystemNote < ApplicationRecord
  belongs_to :client
  belongs_to :user, required: false

  validates_presence_of :body

  def contact_record_type
    "system_note"
  end
end
