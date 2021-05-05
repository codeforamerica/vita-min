# == Schema Information
#
# Table name: clients
#
#  id                                       :bigint           not null, primary key
#  attention_needed_since                   :datetime
#  completion_survey_sent_at                :datetime
#  current_sign_in_at                       :datetime
#  current_sign_in_ip                       :inet
#  failed_attempts                          :integer          default(0), not null
#  first_unanswered_incoming_interaction_at :datetime
#  in_progress_survey_sent_at               :datetime
#  last_incoming_interaction_at             :datetime
#  last_internal_or_outgoing_interaction_at :datetime
#  last_outgoing_interaction_at             :datetime
#  last_sign_in_at                          :datetime
#  last_sign_in_ip                          :inet
#  locked_at                                :datetime
#  login_requested_at                       :datetime
#  login_token                              :string
#  response_needed_since                    :datetime
#  routing_method                           :integer
#  sign_in_count                            :integer          default(0), not null
#  created_at                               :datetime         not null
#  updated_at                               :datetime         not null
#  vita_partner_id                          :bigint
#
# Indexes
#
#  index_clients_on_in_progress_survey_sent_at  (in_progress_survey_sent_at)
#  index_clients_on_login_token                 (login_token)
#  index_clients_on_vita_partner_id             (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class Client < ApplicationRecord
  devise :lockable, :timeoutable, :trackable

  self.per_page = 25

  belongs_to :vita_partner, optional: true
  has_one :intake, dependent: :destroy
  has_many :client_selection_clients, dependent: :destroy
  has_many :client_selections, through: :client_selection_clients
  has_one :consent, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :outgoing_text_messages, dependent: :destroy
  has_many :outgoing_emails, dependent: :destroy
  has_many :incoming_text_messages, dependent: :destroy
  has_many :incoming_emails, dependent: :destroy
  has_many :incoming_portal_messages, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :system_notes, dependent: :destroy
  has_many :tax_returns, dependent: :destroy
  has_many :access_logs
  has_many :outbound_calls, dependent: :destroy
  has_many :users_assigned_to_tax_returns, through: :tax_returns, source: :assigned_user
  accepts_nested_attributes_for :tax_returns
  accepts_nested_attributes_for :intake
  attr_accessor :change_initiated_by
  enum routing_method: { most_org_leads: 0, source_param: 1, zip_code: 2, national_overflow: 3, state: 4 }

  validate :tax_return_assigned_user_access_maintained, if: :vita_partner_id_changed?
  after_update_commit :create_org_change_note, if: :saved_change_to_vita_partner_id?

  def self.delegated_intake_attributes
    [:preferred_name, :email_address, :phone_number, :sms_phone_number, :locale]
  end

  def self.sortable_intake_attributes
    [:created_at, :state_of_residence] + delegated_intake_attributes
  end

  delegate *delegated_intake_attributes, to: :intake
  scope :after_consent, -> { distinct.joins(:tax_returns).merge(TaxReturn.where("status > 100")) }
  scope :greetable, -> do
    greeter_statuses = TaxReturnStatus.available_statuses_for(role_type: GreeterRole::TYPE).values.flatten
    distinct.joins(:tax_returns).where(tax_returns: { status: greeter_statuses })
  end
  scope :assigned_to, ->(user) { joins(:tax_returns).where({ tax_returns: { assigned_user_id: user } }).distinct }
  scope :with_eager_loaded_associations, -> { includes(:vita_partner, :intake, :tax_returns, tax_returns: [:assigned_user]) }
  scope :sla_tracked, -> { distinct.joins(:tax_returns).where(tax_returns: { status: TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_SLA })}
  scope :outgoing_communication_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(arel_table[:first_unanswered_incoming_interaction_at].lteq(breach_threshold_datetime))
  end
  scope :response_needed_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(arel_table[:response_needed_since].lteq(breach_threshold_datetime))
  end
  scope :last_outgoing_interaction_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(arel_table[:last_outgoing_interaction_at].lteq(breach_threshold_datetime))
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
  scope :by_raw_login_token, ->(raw_token) do
    where(login_token: Devise.token_generator.digest(Client, :login_token, raw_token))
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

  scope :with_insufficient_contact_info, -> do
    can_use_email = Intake.where(email_notification_opt_in: "yes").where.not(email_address: nil).where.not(email_address: "")
    can_use_sms = Intake.where(sms_notification_opt_in: "yes").where.not(sms_phone_number: nil).where.not(sms_phone_number: "")
    where.not(intake: can_use_email.or(can_use_sms))
  end

  scope :needs_in_progress_survey, -> do
    where(in_progress_survey_sent_at: nil)
      .includes(:tax_returns).where(tax_returns: { status: "intake_in_progress" })
      .includes(:intake).where("primary_consented_to_service_at < ?", 10.days.ago)
      .includes(:incoming_text_messages).where(incoming_text_messages: { client_id: nil })
      .includes(:incoming_emails).where(incoming_emails: { client_id: nil })
      .includes(:documents).where("documents.client_id IS NULL OR documents.created_at < (interval '1 day' + clients.created_at)")
  end

  scope :accessible_to_user, ->(user) do
    accessible_by(Ability.new(user))
  end

  def self.locale_counts
    counts = joins(:intake).group(:locale).count
    counts["en"] = 0 unless counts.key?("en")
    counts["es"] = 0 unless counts.key?("es")

    nil_count = counts.delete(nil)
    if nil_count.present?
      counts["en"] += nil_count
    end
    counts
  end

  def legal_name
    return unless intake&.primary_first_name? && intake&.primary_last_name?

    "#{intake.primary_first_name} #{intake.primary_last_name}"
  end

  def spouse_legal_name
    return unless intake&.spouse_first_name? && intake&.spouse_last_name?

    "#{intake.spouse_first_name} #{intake.spouse_last_name}"
  end

  def set_response_needed!
    # we don't want to change older dates if response is already needed
    touch(:response_needed_since) unless needs_response?
  end

  def clear_response_needed
    update(response_needed_since: nil)
  end

  def needs_response?
    response_needed_since.present?
  end

  def bank_account_info?
    intake.encrypted_bank_name || intake.encrypted_bank_routing_number || intake.encrypted_bank_account_number
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

  def clients_with_dupe_contact_info
    matching_intakes = Intake.where(
      "email_address = ? OR phone_number = ? OR phone_number = ? OR sms_phone_number = ? OR sms_phone_number = ?",
      intake.email_address,
      intake.phone_number,
      intake.sms_phone_number,
      intake.phone_number,
      intake.sms_phone_number
    ).where.not(id: intake.id)
    Client.after_consent.where(intake: matching_intakes).pluck(:id)
  end

  def preferred_language
    return intake.preferred_interview_language if intake.preferred_interview_language && intake.preferred_interview_language != "en"

    intake.locale || intake.preferred_interview_language
  end

  def request_document_help(doc_type:, help_type:)
    note = SystemNote::DocumentHelp.generate!(client: self, doc_type: doc_type, help_type: help_type)
    tax_returns.map(&:assigned_user).uniq.each do |user|
      UserNotification.create(notifiable_type: "SystemNote::DocumentHelp", notifiable_id: note.id, user: user)
    end
    tax_returns.each { |tax_return| tax_return.update(status: :intake_needs_doc_help) }
    set_response_needed!
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

  def create_org_change_note
    SystemNote::OrganizationChange.generate!(client: self, initiated_by: change_initiated_by)
  end
end
