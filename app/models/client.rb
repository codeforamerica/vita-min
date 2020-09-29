# == Schema Information
#
# Table name: clients
#
#  id               :bigint           not null, primary key
#  email_address    :string
#  phone_number     :string
#  preferred_name   :string
#  sms_phone_number :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  vita_partner_id  :bigint
#
# Indexes
#
#  index_clients_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class Client < ApplicationRecord
  belongs_to :vita_partner, optional: true
  has_many :intakes
  has_many :outgoing_text_messages
  has_many :outgoing_emails
  has_many :incoming_text_messages
  has_many :incoming_emails

  def self.create_from_intake(intake)
    create(
      preferred_name: intake.preferred_name,
      email_address: intake.email_address,
      phone_number: intake.phone_number,
      sms_phone_number: intake.sms_phone_number,
      vita_partner: intake.vita_partner,
    )
  end

  # Returns the phone number formatted for user display, e.g.: "(510) 555-1234"
  def formatted_phone_number
    Phonelib.parse(phone_number).local_number
  end
end
