module Hub
  class ClientIntakeForm < Form
    include FormAttributes
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
                       :sms_notification_opt_in,
                       :email_notification_opt_in,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_email_address,
                       :filing_joint
    validates :primary_first_name, presence: true, allow_blank: false
    validates :primary_last_name, presence: true, allow_blank: false

    def initialize(intake, params = {})
      @intake = intake
      super(params)
    end

    def self.from_intake(intake)
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(intake, existing_attributes(intake).slice(*attribute_keys))
    end

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
