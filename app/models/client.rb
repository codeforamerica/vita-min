# == Schema Information
#
# Table name: clients
#
#  id                                       :bigint           not null, primary key
#  attention_needed_since                   :datetime
#  completion_survey_sent_at                :datetime
#  ctc_experience_survey_sent_at            :datetime
#  ctc_experience_survey_variant            :integer
#  current_sign_in_at                       :datetime
#  current_sign_in_ip                       :inet
#  experience_survey                        :integer          default("unfilled"), not null
#  failed_attempts                          :integer          default(0), not null
#  first_unanswered_incoming_interaction_at :datetime
#  flagged_at                               :datetime
#  in_progress_survey_sent_at               :datetime
#  last_incoming_interaction_at             :datetime
#  last_internal_or_outgoing_interaction_at :datetime
#  last_outgoing_communication_at           :datetime
#  last_seen_at                             :datetime
#  last_sign_in_at                          :datetime
#  last_sign_in_ip                          :inet
#  locked_at                                :datetime
#  login_requested_at                       :datetime
#  login_token                              :string
#  message_tracker                          :jsonb
#  previous_sessions_active_seconds         :integer
#  routing_method                           :integer
#  sign_in_count                            :integer          default(0), not null
#  still_needs_help                         :integer          default("unfilled"), not null
#  triggered_still_needs_help_at            :datetime
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
  has_many :documents, dependent: :destroy
  has_many :documents_requests, dependent: :destroy
  has_one :intake, inverse_of: :client, dependent: :destroy
  has_one :consent, dependent: :destroy
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
  has_many :efile_submissions, through: :tax_returns
  has_many :efile_security_informations, dependent: :destroy
  has_many :recaptcha_scores, dependent: :destroy
  has_many :verification_attempts, dependent: :destroy
  accepts_nested_attributes_for :tax_returns
  accepts_nested_attributes_for :intake
  accepts_nested_attributes_for :efile_security_informations
  attr_accessor :change_initiated_by
  enum routing_method: { most_org_leads: 0, source_param: 1, zip_code: 2, national_overflow: 3, state: 4, at_capacity: 5, returning_client: 6 }, _prefix: :routing_method
  enum still_needs_help: { unfilled: 0, yes: 1, no: 2 }, _prefix: :still_needs_help
  enum experience_survey: { unfilled: 0, positive: 1, neutral: 2, negative: 3 }, _prefix: :experience_survey

  def self.delegated_intake_attributes
    [:preferred_name, :email_address, :phone_number, :sms_phone_number, :locale]
  end

  def self.sortable_intake_attributes
    [:created_at, :state_of_residence] + delegated_intake_attributes
  end

  delegate *delegated_intake_attributes, to: :intake
  scope :after_consent, -> { distinct.joins(:tax_returns).merge(TaxReturn.where.not(state: "intake_before_consent")) }
  scope :greetable, -> do
    greeter_statuses = TaxReturnStateMachine.available_states_for(role_type: GreeterRole::TYPE).values.flatten
    distinct.joins(:tax_returns).where(tax_returns: { state: greeter_statuses })
  end
  scope :assigned_to, ->(user) { joins(:tax_returns).where({ tax_returns: { assigned_user_id: user } }).distinct }
  scope :with_eager_loaded_associations, -> { includes(:vita_partner, :intake, :tax_returns, tax_returns: [:assigned_user]) }
  scope :sla_tracked, -> { distinct.joins(:tax_returns).where.not(tax_returns: { state: TaxReturnStateMachine::EXCLUDED_FROM_SLA }) }
  scope :response_needed_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(arel_table[:flagged_at].lteq(breach_threshold_datetime))
  end

  scope :last_outgoing_communication_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(arel_table[:last_outgoing_communication_at].lteq(breach_threshold_datetime))
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

  scope :first_unanswered_incoming_interaction_communication_breaches, ->(breach_threshold_datetime) do
    sla_tracked.where(arel_table[:first_unanswered_incoming_interaction_at].lteq(breach_threshold_datetime))
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
      order = {column => direction}
      includes(:intake).order(order).distinct
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
      .includes(:tax_returns).where(tax_returns: { state: "intake_in_progress" })
      .includes(:intake).where("primary_consented_to_service_at < ?", 10.days.ago)
      .includes(:incoming_text_messages).where(incoming_text_messages: { client_id: nil })
      .includes(:incoming_emails).where(incoming_emails: { client_id: nil })
      .includes(:documents).where("documents.client_id IS NULL OR documents.created_at < (interval '1 day' + clients.created_at)")
  end

  scope :accessible_to_user, ->(user) do
    accessible_by(Ability.new(user))
  end

  scope :without_pagination, -> do
    # This removes pagination limits
    # https://github.com/kaminari/kaminari#unscoping
    except(:limit, :offset)
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

  def accumulate_total_session_durations
    return if last_seen_at.nil?
    return if last_sign_in_at.nil?

    previous_session_duration = last_seen_at - last_sign_in_at
    # In one case, previous session duration came out negative. This resulted in a negative total session duration,
    # which the IRS rejected. We're not sure why the session duration came out negative, but it was
    # very rare, so we don't worry about it.
    return if previous_session_duration.negative?

    update!(previous_sessions_active_seconds: (previous_sessions_active_seconds || 0) + previous_session_duration)
  end

  def legal_name
    return unless intake&.primary_first_name? && intake&.primary_last_name?

    "#{intake.primary_first_name.strip} #{intake.primary_last_name.strip}"
  end

  def spouse_legal_name
    return unless intake&.spouse_first_name? && intake&.spouse_last_name?

    "#{intake.spouse_first_name.strip} #{intake.spouse_last_name.strip}"
  end

  def flag!
    # we don't want to change older dates if response is already needed
    touch(:flagged_at) unless flagged_at.present?
  end

  def clear_flag!
    update!(flagged_at: nil)
  end

  def flagged?
    flagged_at.present?
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

  def clients_with_dupe_contact_info(is_ctc)
    return [] unless intake

    matching_intakes = Intake.where(
      "email_address = ? OR phone_number = ? OR phone_number = ? OR sms_phone_number = ? OR sms_phone_number = ?",
      intake.email_address,
      intake.phone_number,
      intake.sms_phone_number,
      intake.phone_number,
      intake.sms_phone_number,
    )
    if is_ctc
      matching_intakes = matching_intakes.where(type: "Intake::CtcIntake")
    else
      matching_intakes = matching_intakes.where.not(type: "Intake::CtcIntake")
    end
    Client.where.not(id: id).after_consent.where(intake: matching_intakes).pluck(:id)
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
    tax_returns.each { |tax_return| tax_return.transition_to(:intake_needs_doc_help) }
  end

  def forward_message_to_intercom?
    return false unless AdminToggle.current_value_for(AdminToggle::FORWARD_MESSAGES_TO_INTERCOM, default: false)

    !online_ctc? && tax_returns.map(&:current_state).all? { |state| TaxReturnStateMachine::FORWARD_TO_INTERCOM_STATES.include? state&.to_sym }
  end

  # TODO: Replace with accurate implementation
  def first_sign_in_ip
    current_sign_in_ip
  end

  def online_ctc?
    intake.is_ctc? && intake.tax_returns.any? { |tr| tr.service_type == "online_intake" }
  end

  def recaptcha_scores_average
    return efile_security_informations.last&.recaptcha_score unless recaptcha_scores.present?

    (recaptcha_scores.map(&:score).sum / recaptcha_scores.size).round(2)
  end
end
