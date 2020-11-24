# == Schema Information
#
# Table name: clients
#
#  id                           :bigint           not null, primary key
#  last_incoming_interaction_at :datetime
#  last_interaction_at          :datetime
#  response_needed_since        :datetime
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
  has_many :documents
  has_many :outgoing_text_messages
  has_many :outgoing_emails
  has_many :incoming_text_messages
  has_many :incoming_emails
  has_many :notes
  has_many :system_notes
  has_many :tax_returns

  def self.delegated_intake_attributes
    [:preferred_name, :email_address, :phone_number, :sms_phone_number, :locale]
  end

  delegate *delegated_intake_attributes, to: :intake
  scope :after_consent, -> { distinct.joins(:tax_returns).merge(TaxReturn.where("status > 100")) }
  scope :assigned_to, ->(user) { joins(:tax_returns).where({ tax_returns: { assigned_user_id: user } }).distinct }

  scope :delegated_order, ->(column, direction) do
    raise ArgumentError, "column and direction are required" if !column || !direction

    if delegated_intake_attributes.include? column.to_sym
      column_names = ["clients.*"] + delegated_intake_attributes.map { |intake_column_name| "intakes.#{intake_column_name}" }
      select(column_names).joins(:intake).merge(Intake.order(Hash[column, direction])).distinct
    else
      includes(:intake).order(Hash[column, direction]).distinct
    end
  end

  def legal_name
    return unless intake&.primary_first_name? && intake&.primary_last_name?

    "#{intake.primary_first_name} #{intake.primary_last_name}"
  end

  def clear_response_needed
    update(response_needed_since: nil)
  end

  def needs_response?
    response_needed_since.present?
  end

  def destroy_completely
    intake.ticket_statuses.destroy_all
    intake.dependents.destroy_all
    DocumentsRequest.where(intake: intake).destroy_all
    documents.destroy_all
    intake.documents.destroy_all
    incoming_emails.destroy_all
    incoming_text_messages.destroy_all
    outgoing_emails.destroy_all
    outgoing_text_messages.destroy_all
    notes.destroy_all
    system_notes.destroy_all
    tax_returns.destroy_all
    intake.destroy
    destroy
  end
end
