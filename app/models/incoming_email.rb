# == Schema Information
#
# Table name: incoming_emails
#
#  id                 :bigint           not null, primary key
#  attachment_count   :integer
#  body_html          :string
#  body_plain         :string
#  from               :citext           not null
#  received           :string
#  received_at        :datetime         not null
#  recipient          :string           not null
#  sender             :string           not null
#  stripped_html      :string
#  stripped_signature :string
#  stripped_text      :string
#  subject            :string
#  to                 :citext
#  user_agent         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  client_id          :bigint           not null
#  message_id         :string
#
# Indexes
#
#  index_incoming_emails_on_client_id   (client_id)
#  index_incoming_emails_on_created_at  (created_at)
#
class IncomingEmail < ApplicationRecord
  include ContactRecord

  belongs_to :client
  has_many :documents, as: :contact_record

  after_create { InteractionTrackingService.record_incoming_interaction(client) }

  def body
    stripped_text || body_plain
  end

  def datetime
    received_at
  end
end
