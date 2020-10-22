# == Schema Information
#
# Table name: clients
#
#  id                           :bigint           not null, primary key
#  email_address                :string
#  last_incoming_interaction_at :datetime
#  last_interaction_at          :datetime
#  phone_number                 :string
#  preferred_name               :string
#  response_needed_since        :datetime
#  sms_phone_number             :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  vita_partner_id              :bigint
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
  has_one :intake
  # has_many :documents
  has_many :outgoing_text_messages
  has_many :outgoing_emails
  has_many :incoming_text_messages
  has_many :incoming_emails
  has_many :notes
  has_many :tax_returns

  delegate :documents, to: :intake
  
  def legal_name
    return unless intake&.primary_first_name? && intake&.primary_last_name?

    "#{intake.primary_first_name} #{intake.primary_last_name}"
  end

  def self.create_from_intake(intake)
    create(
      preferred_name: intake.preferred_name,
      email_address: intake.email_address,
      phone_number: intake.phone_number,
      sms_phone_number: intake.sms_phone_number,
      vita_partner: intake.vita_partner,
      # documents: intake.documents,
      intake: intake
    )
  end

  def clear_response_needed
    update(response_needed_since: nil)
  end

  def needs_response?
    response_needed_since.present?
  end
end
