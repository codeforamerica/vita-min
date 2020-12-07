module Hub
  class CreateClientForm < ClientForm
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
    attr_accessor :tax_returns, :tax_returns_attributes, :client, :intake

    # Additional validations inherited from parent ClientForm
    validates :vita_partner_id, presence: true, allow_blank: false
    validates :signature_method, presence: true
    validates :state_of_residence, inclusion: { in: States.keys }
    validate :tax_return_required_fields_valid
    validate :at_least_one_tax_return_present

    def initialize(attributes = {})
      @tax_returns = TaxReturn.filing_years.map { |year| TaxReturn.new(year: year) }
      super(attributes)
    end

    def save
      return false unless valid?

      Client.create(
        vita_partner_id: attributes_for(:intake)[:vita_partner_id],
        intake_attributes: attributes_for(:intake),
        tax_returns_attributes: @tax_returns_attributes.map { |_, v| create_tax_return_for_year?(v[:year]) ? tax_return_defaults.merge(v) : nil }.compact
      )
    end

    def self.permitted_params
      params = CreateClientForm.attribute_names
      params.delete(:tax_returns_attributes)
      params.push(tax_returns_attributes: {})
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

    def opted_in_sms?
      sms_notification_opt_in == "yes"
    end

    def opted_in_email?
      email_notification_opt_in == "yes"
    end

    def at_least_one_tax_return_present
      tax_return_count = 0
      @tax_returns_attributes&.each do |_, v|
        tax_return_count += 1 if create_tax_return_for_year?(v[:year])
      end
      errors.add(:tax_returns_attributes, I18n.t("forms.errors.at_least_one_year")) unless tax_return_count.positive?
    end

    def at_least_one_contact_method
      unless opted_in_email? || opted_in_sms?
        errors.add(:communication_preference, I18n.t("forms.errors.need_one_communication_method"))
      end
    end
  end
end
