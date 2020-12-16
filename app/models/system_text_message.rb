# == Schema Information
#
# Table name: system_text_messages
#
#  id              :bigint           not null, primary key
#  body            :string           not null
#  sent_at         :datetime         not null
#  to_phone_number :string           not null
#  twilio_sid      :string
#  twilio_status   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :bigint           not null
#
# Indexes
#
#  index_system_text_messages_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class SystemTextMessage < ApplicationRecord
  include ContactRecord

  belongs_to :client
  validates_presence_of :body
  validates_presence_of :sent_at
  validates :to_phone_number, phone: true, format: { with: /\A\+1[0-9]{10}\z/ }

  def datetime
    sent_at
  end

  def author
    "GetYourRefund Team"
  end
end
