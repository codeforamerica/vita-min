# == Schema Information
#
# Table name: clients
#
#  id                           :bigint           not null, primary key
#  attention_needed_since       :datetime
#  current_sign_in_at           :datetime
#  current_sign_in_ip           :string
#  failed_attempts              :integer          default(0), not null
#  last_incoming_interaction_at :datetime
#  last_interaction_at          :datetime
#  last_sign_in_at              :datetime
#  last_sign_in_ip              :string
#  locked_at                    :datetime
#  sign_in_count                :integer          default(0), not null
#  unlock_token                 :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  vita_partner_id              :bigint
#
# Indexes
#
#  index_clients_on_unlock_token     (unlock_token) UNIQUE
#  index_clients_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class Client < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :validatable
  devise :lockable, :timeoutable, :trackable

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
  has_many :access_logs
  has_many :outbound_calls
  accepts_nested_attributes_for :tax_returns
  accepts_nested_attributes_for :intake

  def self.delegated_intake_attributes
    [:preferred_name, :email_address, :phone_number, :sms_phone_number, :locale]
  end

  def self.sortable_intake_attributes
    [:primary_consented_to_service_at, :state_of_residence] + delegated_intake_attributes
  end

  delegate *delegated_intake_attributes, to: :intake
  scope :after_consent, -> { distinct.joins(:tax_returns).merge(TaxReturn.where("status > 100")) }
  scope :assigned_to, ->(user) { joins(:tax_returns).where({ tax_returns: { assigned_user_id: user } }).distinct }

  scope :delegated_order, ->(column, direction) do
    raise ArgumentError, "column and direction are required" if !column || !direction

    if sortable_intake_attributes.include? column.to_sym
      column_names = ["clients.*"] + sortable_intake_attributes.map { |intake_column_name| "intakes.#{intake_column_name}" }
      select(column_names).joins(:intake).merge(Intake.order(Hash[column, direction])).distinct
    else
      includes(:intake).order(Hash[column, direction]).distinct
    end
  end
  
  def legal_name
    return unless intake&.primary_first_name? && intake&.primary_last_name?

    "#{intake.primary_first_name} #{intake.primary_last_name}"
  end

  def clear_attention_needed
    update(attention_needed_since: nil)
  end

  def needs_attention?
    attention_needed_since.present?
  end

  def bank_account_info?
    intake.encrypted_bank_name || intake.encrypted_bank_routing_number || intake.encrypted_bank_account_number
  end

  def destroy_completely
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
