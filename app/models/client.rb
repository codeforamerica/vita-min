# == Schema Information
#
# Table name: clients
#
#  id                                       :bigint           not null, primary key
#  attention_needed_since                   :datetime
#  current_sign_in_at                       :datetime
#  current_sign_in_ip                       :inet
#  failed_attempts                          :integer          default(0), not null
#  first_unanswered_incoming_interaction_at :datetime
#  last_incoming_interaction_at             :datetime
#  last_internal_or_outgoing_interaction_at :datetime
#  last_sign_in_at                          :datetime
#  last_sign_in_ip                          :inet
#  locked_at                                :datetime
#  login_requested_at                       :datetime
#  login_token                              :string
#  routing_method                           :integer
#  sign_in_count                            :integer          default(0), not null
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  vita_partner_id                          :bigint
#
# Indexes
#
#  index_clients_on_login_token      (login_token)
#  index_clients_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class Client < ApplicationRecord
  devise :lockable, :timeoutable, :trackable

  self.per_page = 25

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
  has_many :users_assigned_to_tax_returns, through: :tax_returns, source: :assigned_user
  accepts_nested_attributes_for :tax_returns
  accepts_nested_attributes_for :intake
  enum routing_method: { most_org_leads: 0, source_param: 1, zip_code: 2, national_overflow: 3, state: 4 }

  validate :tax_return_assigned_user_access_maintained, if: :vita_partner_id_changed?

  def self.delegated_intake_attributes
    [:preferred_name, :email_address, :phone_number, :sms_phone_number, :locale]
  end

  def self.sortable_intake_attributes
    [:primary_consented_to_service_at, :state_of_residence] + delegated_intake_attributes
  end

  delegate *delegated_intake_attributes, to: :intake
  scope :after_consent, -> { distinct.joins(:tax_returns).merge(TaxReturn.where("status > 100")) }
  scope :assigned_to, ->(user) { joins(:tax_returns).where({ tax_returns: { assigned_user_id: user } }).distinct }
  scope :with_eager_loaded_associations, -> { includes(:vita_partner, :intake, :tax_returns, tax_returns: [:assigned_user]) }
  scope :sla_tracked, -> { distinct.joins(:tax_returns).where.not(tax_returns: { status: TaxReturnStatus::EXCLUDED_STATUSES })}
  scope :outgoing_communication_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(arel_table[:first_unanswered_incoming_interaction_at].lteq(breach_threshold_datetime))
  end
  scope :attention_needed_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(arel_table[:attention_needed_since].lteq(breach_threshold_datetime))
  end
  scope :outgoing_interaction_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(
      arel_table[:first_unanswered_incoming_interaction_at].lteq(breach_threshold_datetime)
    ).where(
      arel_table[:last_internal_or_outgoing_interaction_at].lt(
        arel_table[:first_unanswered_incoming_interaction_at]
      ).or(arel_table[:last_internal_or_outgoing_interaction_at].eq(nil))
    )
  end
  scope :delegated_order, ->(column, direction) do
    raise ArgumentError, "column and direction are required" if !column || !direction

    if sortable_intake_attributes.include? column.to_sym
      column_names = ["clients.*"] + sortable_intake_attributes.map { |intake_column_name| "intakes.#{intake_column_name}" }
      select(column_names).joins(:intake).merge(Intake.order(Hash[column, direction])).distinct
    else
      includes(:intake).order(Hash[column, direction]).distinct
    end
  end

  scope :by_contact_info, ->(email_address:, phone_number:) do
    email_matches = email_address.present? ? Intake.where(email_address: email_address) : Intake.none
    spouse_email_matches = email_address.present? ? Intake.where(spouse_email_address: email_address) : Intake.none
    phone_number_matches = phone_number.present? ? Intake.where(phone_number: phone_number) : Intake.none
    sms_phone_number_matches = phone_number.present? ? Intake.where(sms_phone_number: phone_number) : Intake.none
    where(intake: email_matches.or(spouse_email_matches).or(phone_number_matches).or(sms_phone_number_matches))
  end

  def legal_name
    return unless intake&.primary_first_name? && intake&.primary_last_name?

    "#{intake.primary_first_name} #{intake.primary_last_name}"
  end

  def spouse_legal_name
    return unless intake&.spouse_first_name? && intake&.spouse_last_name?

    "#{intake.spouse_first_name} #{intake.spouse_last_name}"
  end

  def set_attention_needed
    return true if needs_attention?

    return touch(:attention_needed_since)
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

  def increment_failed_attempts
    super
    if attempts_exceeded?
      lock_access! unless access_locked?
    end
  end

  def generate_login_link
    # Compute a new login URL. This invalidates any existing login URLs.
    raw_token, encrypted_token = Devise.token_generator.generate(Client, :login_token)
    update(
      login_token: encrypted_token,
      login_requested_at: DateTime.now
    )
    Rails.application.routes.url_helpers.portal_client_login_url(id: raw_token)
  end

  private

  def tax_return_assigned_user_access_maintained
    # assuming the vita_partner was changed
    # if any tax returns have assigned users ...
    if persisted? && users_assigned_to_tax_returns.exists?
      # ... find out who would lose access based on the new partner
      users_who_would_lose_access = users_assigned_to_tax_returns.select do |user|
        user.accessible_vita_partners.where(id: vita_partner_id).empty?
      end
      if users_who_would_lose_access.present?
        affected_user_names = users_who_would_lose_access.map(&:name).join(", ")
        errors.add(:vita_partner_id,
          I18n.t(
            "clients.errors.tax_return_assigned_user_access",
            new_partner: vita_partner.name,
            affected_users: affected_user_names
          )
        )
      end
    end
  end
end
