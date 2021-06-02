module Hub
  class UpdateClientForm < ClientForm
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
                       :primary_last_four_ssn,
                       :spouse_last_four_ssn,
                       :sms_notification_opt_in,
                       :email_notification_opt_in,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_email_address,
                       :filing_joint,
                       :interview_timing_preference,
                       :timezone,
                       :state_of_residence,
                       :with_general_navigator,
                       :with_incarcerated_navigator,
                       :with_limited_english_navigator,
                       :with_unhoused_navigator
    attr_accessor :dependents_attributes

    validate :dependents_attributes_required_fields

    def initialize(client, params = {})
      @client = client
      @dependents_attributes ||= []
      super(params)
      # parent Form class creates setters for each attribute -- won't work til super is called!
      self.preferred_name = preferred_name.presence || "#{primary_first_name} #{primary_last_name}"
    end

    def dependents
      @dependents_attributes&.each do |_, v|
        next if v["_destroy"] == "1"

        v.delete :_destroy # delete falsey _destroy value on reload to initialize dependent again
        @client.intake.dependents.new formatted_dependent_attrs(v)
      end
      @client.intake.dependents
    end

    def self.existing_attributes(intake)
      non_model_attrs = { primary_last_four_ssn: intake.primary_last_four_ssn, spouse_last_four_ssn: intake.spouse_last_four_ssn }
      super.merge(non_model_attrs)
    end

    def self.from_client(client)
      intake = client.intake
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(client, existing_attributes(intake).slice(*attribute_keys))
    end

    def save
      return false unless valid?

      formatted_dependents_attributes = @dependents_attributes&.each do |k, v|
        { k => formatted_dependent_attrs(v) }
      end
      @client.intake.update(attributes_for(:intake).merge(dependents_attributes: formatted_dependents_attributes))
    end

    def self.permitted_params
      client_intake_attributes = attribute_names
      client_intake_attributes.delete(:dependents_attributes)
      client_intake_attributes.push({ dependents_attributes: {} })
    end

    private

    def dependents_attributes_required_fields
      empty_fields = []
      @dependents_attributes&.each do |_, v|
        vals = HashWithIndifferentAccess.new v
        next if vals["_destroy"] == "1"

        empty_fields << "first_name" if vals["first_name"].blank?
        empty_fields << "last_name" if vals["last_name"].blank?
        empty_fields << "birth_date" if [vals["birth_date_year"], vals["birth_date_month"], vals["birth_date_year"]].any?(&:blank?)
      end
      if empty_fields.present?
        error_message = I18n.t("forms.errors.dependents", attrs: empty_fields.uniq.map { |field| I18n.t("forms.errors.dependents_attributes.#{field}") }.join(", "))
        errors.add(:dependents_attributes, error_message)
      end
    end

    def formatted_dependent_attrs(attrs)
      if attrs[:birth_date_month] && attrs[:birth_date_month] && attrs[:birth_date_year]
        attrs[:birth_date] = "#{attrs[:birth_date_year]}-#{attrs[:birth_date_month]}-#{attrs[:birth_date_day]}"
      end
      attrs.except!(:birth_date_month, :birth_date_day, :birth_date_year)
    end
  end
end