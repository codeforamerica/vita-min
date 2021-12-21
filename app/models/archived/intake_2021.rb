module Archived
  class Intake2021 < ApplicationRecord
    self.table_name = 'archived_intakes_2021'

    def self.discriminate_class_for_record(record)
      if record['type'] == 'Intake::CtcIntake'
        Archived::Intake::CtcIntake2021
      elsif record['type'] == 'Intake::GyrIntake'
        Archived::Intake::GyrIntake2021
      else
        self
      end
    end

    include PgSearch::Model

    def self.searchable_fields
      [:client_id, :primary_first_name, :primary_last_name, :preferred_name, :spouse_first_name, :spouse_last_name, :email_address, :phone_number, :sms_phone_number]
    end

    pg_search_scope :search, against: searchable_fields, using: { tsearch: { prefix: true, tsvector_column: 'searchable_data' } }

    has_many :documents, dependent: :destroy
    has_many :dependents, -> { order(created_at: :asc) }, inverse_of: :intake, dependent: :destroy, class_name: 'Archived::Dependent2021', foreign_key: 'archived_intakes_2021_id'
    belongs_to :client, inverse_of: :intake, optional: true
    has_many :tax_returns, through: :client
    belongs_to :vita_partner, optional: true
    accepts_nested_attributes_for :dependents, allow_destroy: true
    scope :completed_yes_no_questions, -> { where.not(completed_yes_no_questions_at: nil) }
    validates :email_address, 'valid_email_2/email': true
    validates :phone_number, :sms_phone_number, allow_blank: true, e164_phone: true
    validates_presence_of :visitor_id

    before_validation do
      self.primary_ssn = self.primary_ssn.remove(/\D/) if primary_ssn_changed? && self.primary_ssn
      self.spouse_ssn = self.spouse_ssn.remove(/\D/) if spouse_ssn_changed? && self.spouse_ssn
    end

    before_save do
      self.needs_to_flush_searchable_data_set_at = Time.current
      if email_address.present?
        self.email_domain = email_address.split('@').last.downcase
        self.canonical_email_address = compute_canonical_email_address
      end
      self.primary_last_four_ssn = primary_ssn&.last(4) if encrypted_primary_ssn_changed?
      self.spouse_last_four_ssn = spouse_ssn&.last(4) if encrypted_spouse_ssn_changed?
    end

    attr_encrypted :primary_last_four_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    attr_encrypted :spouse_last_four_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    attr_encrypted :primary_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    attr_encrypted :spouse_ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    attr_encrypted :bank_name, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    attr_encrypted :bank_routing_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    attr_encrypted :bank_account_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

    enum already_filed: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :already_filed
    enum email_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :email_notification_opt_in
    enum sms_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :sms_notification_opt_in
    enum signature_method: { online: 0, in_person: 1 }, _prefix: :signature_method
    enum bank_account_type: { unfilled: 0, checking: 1, savings: 2, unspecified: 3 }, _prefix: :bank_account_type
    enum primary_consented_to_service: { unfilled: 0, yes: 1, no: 2 }, _prefix: :primary_consented_to_service
    enum refund_payment_method: { unfilled: 0, direct_deposit: 1, check: 2 }, _prefix: :refund_payment_method
    enum claim_owed_stimulus_money: { unfilled: 0, yes: 1, no: 2 }, _prefix: :claim_owed_stimulus_money
    enum primary_tin_type: { ssn: 0, itin: 1, none: 2, ssn_no_employment: 3 }, _prefix: :primary_tin_type
    enum spouse_tin_type: { ssn: 0, itin: 1, none: 2, ssn_no_employment: 3 }, _prefix: :spouse_tin_type

    NAVIGATOR_TYPES = {
      general: {
        param: "1",
        display_name: "General",
        field_name: :with_general_navigator
      },
      incarcerated: {
        param: "2",
        display_name: "Incarcerated/reentry",
        field_name: :with_incarcerated_navigator
      },
      limited_english: {
        param: "3",
        display_name: "Limited English",
        field_name: :with_limited_english_navigator
      },
      unhoused: {
        param: "4",
        display_name: "Unhoused",
        field_name: :with_unhoused_navigator
      }
    }

    def is_ctc?
      false
    end

    # Returns the phone number formatted for user display, e.g.: "(510) 555-1234"
    def formatted_phone_number
      Phonelib.parse(phone_number).local_number
    end

    def formatted_sms_phone_number
      Phonelib.parse(sms_phone_number).local_number
    end

    # Returns the sms phone number in the E164 standardized format, e.g.: "+15105551234"
    def standardized_sms_phone_number
      PhoneParser.normalize(sms_phone_number)
    end

    def primary_full_name
      parts = [primary_first_name, primary_last_name]
      parts << primary_suffix if primary_suffix.present?
      parts.join(' ')
    end

    def spouse_full_name
      parts = [spouse_first_name, spouse_last_name]
      parts << spouse_suffix if spouse_suffix.present?
      parts.join(' ')
    end

    def primary_user
      users.where.not(is_spouse: true).first
    end

    def spouse
      users.where(is_spouse: true).first
    end

    def consented?
      primary_consented_to_service_at.present?
    end

    def pdf
      IntakePdf.new(self).output_file
    end

    def consent_pdf
      ConsentPdf.new(self).output_file
    end

    def referrer_domain
      URI.parse(referrer).host if referrer.present?
    end

    def state_of_residence_name
      States.name_for_key(state_of_residence)
    end

    def had_a_job?
      job_count.present? && job_count > 0
    end

    def eligible_for_vita?
      # if any are unfilled this will return false
      had_farm_income_no? && had_rental_income_no? && income_over_limit_no?
    end

    def any_students?
      was_full_time_student_yes? ||
        spouse_was_full_time_student_yes? ||
        had_student_in_family_yes? ||
        dependents.where(was_student: "yes").any?
    end

    def spouse_name_or_placeholder
      return I18n.t("models.intake.your_spouse") unless spouse_first_name.present?
      spouse_full_name
    end

    def student_names
      names = []
      names << primary_full_name if was_full_time_student_yes?
      names << spouse_name_or_placeholder if spouse_was_full_time_student_yes?
      names += dependents.where(was_student: "yes").map(&:full_name)
      names
    end

    def external_id
      return unless id.present?

      ["intake", id].join("-")
    end

    def get_or_create_spouse_auth_token
      return spouse_auth_token if spouse_auth_token.present?

      new_token = SecureRandom.urlsafe_base64(8)
      update(spouse_auth_token: new_token)
      new_token
    end

    def most_recent_filing_year
      filing_years.first || TaxReturn.current_tax_year
    end

    def filing_years
      tax_returns.pluck(:year).sort.reverse
    end

    def filer_count
      filing_joint_yes? ? 2 : 1
    end

    def include_bank_details?
      refund_payment_method_direct_deposit? || balance_pay_from_bank_yes?
    end

    def year_before_most_recent_filing_year
      most_recent_filing_year && most_recent_filing_year - 1
    end

    def contact_info_filtered_by_preferences
      contact_info = {}
      contact_info[:sms_phone_number] = sms_phone_number if sms_notification_opt_in_yes?
      contact_info[:email] = email_address if email_notification_opt_in_yes?
      contact_info
    end

    def opted_into_notifications?
      sms_notification_opt_in_yes? || email_notification_opt_in_yes?
    end

    def had_earned_income?
      had_a_job? || had_wages_yes? || had_self_employment_income_yes?
    end

    def had_dependents_under?(yrs)
      dependents.any? { |dependent| dependent.yr_2020_age < yrs }
    end

    def needs_help_with_backtaxes?
      TaxReturn.backtax_years.any? { |year| send("needs_help_#{year}_yes?") }
    end

    def formatted_contact_preferences
      text = "Prefers notifications by:\n"
      text << "    • Text message\n" if sms_notification_opt_in_yes?
      text << "    • Email\n" if email_notification_opt_in_yes?
      text
    end

    def formatted_mailing_address
      return "N/A" unless street_address
      <<~ADDRESS
      #{street_address} #{street_address2}
      #{city}, #{state} #{zip_code}
      ADDRESS
    end

    def update_or_create_13614c_document(filename)
      ClientPdfDocument.create_or_update(
        output_file: pdf,
        document_type: DocumentTypes::Form13614C,
        client: client,
        filename: filename
      )
    end

    def update_or_create_14446_document(filename)
      ClientPdfDocument.create_or_update(
        output_file: consent_pdf,
        document_type: DocumentTypes::Form14446,
        client: client,
        filename: filename
      )
    end

    def update_or_create_additional_consent_pdf
      ClientPdfDocument.create_or_update(
        output_file: AdditionalConsentPdf.new(client).output_file,
        document_type: DocumentTypes::AdditionalConsentForm,
        client: client,
        filename: "additional-consent-2021.pdf"
      )
    end

    def might_encounter_delayed_service?
      vita_partner.at_capacity?
    end

    def set_navigator(param)
      _, navigator_type = NAVIGATOR_TYPES.find { | _, type| type[:param] == param }
      return unless navigator_type

      self.update(navigator_type[:field_name] => true)
    end

    def drop_off?
      tax_returns.pluck(:service_type).any? "drop_off"
    end

    def navigator_display_names
      names = []
      NAVIGATOR_TYPES.each do |_, type|
        if self.send(type[:field_name])
          names << type[:display_name]
        end
      end
      names.join(', ')
    end

    def self.refresh_search_index(limit: 10_000)
      now = Time.current
      ids = where('needs_to_flush_searchable_data_set_at < ?', now)
        .limit(limit)
        .pluck(:id)

      where(id: ids)
        .where('needs_to_flush_searchable_data_set_at < ?', now)
        .update_all(<<-SQL)
        searchable_data = to_tsvector('simple', array_to_string(ARRAY[#{searchable_fields.map { |f| "#{f}::text"}.join(",\n") }], ' ', '')),
        needs_to_flush_searchable_data_set_at = NULL
      SQL
    end

    def new_dependent_token
      verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
      verifier.generate(SecureRandom.base36(24))
    end

    def compute_canonical_email_address
      if email_domain == 'gmail.com'
        username, domain = email_address.split('@')
        [username.gsub('.', ''), domain].join('@').downcase
      else
        email_address.downcase
      end
    end
  end
end
