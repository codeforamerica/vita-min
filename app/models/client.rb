# == Schema Information
#
# Table name: clients
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Client < ApplicationRecord
  belongs_to :vita_partner, optional: true
  has_one :intake
  has_many :outgoing_text_messages
  has_many :outgoing_emails
  has_many :incoming_text_messages
  has_many :incoming_emails
  has_many :notes

  delegate :preferred_name, :email_address, :phone_number, :sms_phone_number, :vita_partner, to: :intake

  def legal_name
    return unless intake&.primary_first_name? && intake&.primary_last_name?

    "#{intake.primary_first_name} #{intake.primary_last_name}"
  end
end
