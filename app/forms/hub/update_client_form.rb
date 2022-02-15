module Hub
  class UpdateClientForm < ClientForm
    set_attributes_for :intake,
                       :primary_first_name,
                       :primary_last_name,
                       :preferred_name,
                       :preferred_interview_language,
                       :married,
                       :separated,
                       :widowed,
                       :lived_with_spouse,
                       :divorced,
                       :divorced_year,
                       :separated_year,
                       :widowed_year,
                       :email_address,
                       :phone_number,
                       :sms_phone_number,
                       :street_address,
                       :city,
                       :state,
                       :zip_code,
                       :primary_ssn,
                       :spouse_ssn,
                       :primary_tin_type,
                       :spouse_tin_type,
                       :sms_notification_opt_in,
                       :email_notification_opt_in,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_email_address,
                       :filing_joint,
                       :interview_timing_preference,
                       :timezone,
                       :state_of_residence,
                       :used_itin_certifying_acceptance_agent,
                       :with_general_navigator,
                       :with_incarcerated_navigator,
                       :with_limited_english_navigator,
                       :with_unhoused_navigator

    validates :state_of_residence, inclusion: { in: States.keys }
    validates :preferred_interview_language, presence: true, allow_blank: false

    validates :primary_tin_type, presence: true
    validates :primary_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include? primary_tin_type }
    validates :primary_ssn, individual_taxpayer_identification_number: true, if: -> { primary_tin_type == "itin"}

    validates_confirmation_of :spouse_ssn, if: -> { filing_joint == "yes" }
    validates :spouse_ssn, social_security_number: true, if: -> { ["ssn", "ssn_no_employment"].include?(spouse_tin_type) && filing_joint == "yes"}
    validates :spouse_ssn, individual_taxpayer_identification_number: true, if: -> { spouse_tin_type == "itin" && filing_joint == "yes" }

    attr_accessor :client

    before_validation do
      self.used_itin_certifying_acceptance_agent ||= false # TODO: Remove after next release; this line protects forms in flight during a deploy.
    end

    def initialize(client, params = {})
      @client = client
      super(params)
    end

    def self.existing_attributes(intake)
      non_model_attrs = { primary_ssn: intake.primary_ssn, spouse_ssn: intake.spouse_ssn }
      super.merge(non_model_attrs)
    end

    def self.from_client(client)
      intake = client.intake
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(client, existing_attributes(intake).slice(*attribute_keys))
    end

    def dependent_validation_context
      @client.intake.is_ctc? ? :ctc_valet_form : nil
    end

    def save
      return false unless valid?

      @client.intake.update(attributes_for(:intake).merge(dependents_attributes: formatted_dependents_attributes))
    end
  end
end
