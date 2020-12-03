module Hub
  class CreateClientForm < Form
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
                       :state_of_residence,
                       :zip_code,
                       :sms_notification_opt_in,
                       :email_notification_opt_in,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_email_address,
                       :filing_joint,
                       :interview_timing_preference,
                       :timezone,
                       :vita_partner_id,
                       :needs_help_2020,
                       :needs_help_2019,
                       :needs_help_2018,
                       :needs_help_2017,
                       :signature_method
    set_attributes_for :tax_return, :service_type
    before_validation :parse_phone_numbers

    attr_accessor :tax_returns, :tax_returns_attributes, :client, :intake
    validates :primary_first_name, presence: true, allow_blank: false
    validates :primary_last_name, presence: true, allow_blank: false
    validates :vita_partner_id, presence: true, allow_blank: false
    validates :phone_number, allow_blank: true, phone: true
    validates :sms_phone_number, phone: true, if: -> { sms_phone_number.present? }
    validates :sms_phone_number, presence: true, allow_blank: false, if: -> { opted_in_sms? }
    validates :email_address, presence: true, allow_blank: false, 'valid_email_2/email': true
    validates :preferred_interview_language, presence: true, allow_blank: false
    validates :signature_method, presence: true
    validates :state_of_residence, inclusion: { in: States.keys }
    validate :tax_return_required_fields_valid
    validate :at_least_one_tax_return_present
    validate :at_least_one_contact_method

    def opted_in_sms?
      attributes_for(:intake)[:sms_notification_opt_in] == "yes"
    end

    def opted_in_email?
      attributes_for(:intake)[:email_notification_opt_in] == "yes"
    end

    def initialize(attributes = {})
      @tax_returns = TaxReturn.filing_years.map { |year| TaxReturn.new(year: year) }
      super(attributes)
    end

    def save
      vita_partner_id = attributes_for(:intake)[:vita_partner_id]
      ActiveRecord::Base.transaction do
        @intake = Intake.create!(attributes_for(:intake).merge(
                                   client: Client.create!(vita_partner_id: vita_partner_id),
                                   preferred_name: calc_preferred_name
                                 ))
        @tax_returns_attributes&.each do |_, v|
          intake.client.tax_returns.create(tax_return_defaults.merge(v)) if create_tax_return_for_year?(v[:year])
        end
      end
      @client = @intake.client
    end

    def self.permitted_params
      params = CreateClientForm.attribute_names
      params.delete(:tax_returns_attributes)
      params.push(tax_returns_attributes: {})
    end

    def calc_preferred_name
      attributes_for(:intake)[:preferred_name].presence ||
        "#{attributes_for(:intake)[:primary_first_name]} #{attributes_for(:intake)[:primary_last_name]}"
    end

    private

    def tax_return_defaults
      { status: :intake_needs_assignment }.merge(attributes_for(:tax_return))
    end

    def create_tax_return_for_year?(year)
      attributes_for(:intake)["needs_help_#{year}".to_sym] == "yes"
    end

    def tax_return_required_fields_valid
      required_attrs = [:certification_level, :is_hsa]
      missing_attrs = []
      @tax_returns_attributes&.each do |_, v|
        next unless create_tax_return_for_year?(v[:year])
        values = HashWithIndifferentAccess.new(v)
        required_attrs.each { |attr| missing_attrs.push(attr) if values[attr].blank? }
      end
      if missing_attrs.uniq.present?
        error_message = I18n.t("forms.errors.tax_returns", attrs: missing_attrs.uniq.map { |field| I18n.t("forms.errors.tax_returns_attributes.#{field}") }.join(", "))
        errors.add(:tax_returns_attributes, error_message)
      end
    end

    def at_least_one_tax_return_present
      tax_return_count = 0
      @tax_returns_attributes&.each do |_, v|
        tax_return_count += 1 if create_tax_return_for_year?(v[:year])
      end
      errors.add(:tax_returns_attributes, I18n.t("forms.errors.at_least_one_year")) unless tax_return_count.positive?
    end

    def parse_phone_numbers
      phone_number_attrs = [:phone_number, :sms_phone_number]
      phone_number_attrs.each do |attr|
        value = send(attr)
        next unless value.present?

        unless value[0] == "1" || value[0..1] == "+1"
          value = "1#{value}"
        end
        send("#{attr}=", Phonelib.parse(value).sanitized)
      end
    end

    def at_least_one_contact_method
      unless opted_in_email? || opted_in_sms?
        errors.add(:communication_preference, I18n.t("forms.errors.need_one_communication_method"))
      end
    end
  end
end