# == Schema Information
#
# Table name: incoming_text_messages
#
#  id                :bigint           not null, primary key
#  body              :string           not null
#  from_phone_number :string           not null
#  received_at       :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  client_id         :bigint           not null
#
# Indexes
#
#  index_incoming_text_messages_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class IncomingTextMessage < ApplicationRecord
  include ContactRecord

  belongs_to :client
  validates_presence_of :body
  validates_presence_of :received_at

  def datetime
    received_at
  end

  def author
    Phonelib.parse(from_phone_number).local_number
  end
end
