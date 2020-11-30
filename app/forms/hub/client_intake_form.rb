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
                       :filing_joint,
                       :interview_timing_preference,
                       :timezone,
                       :dependents_attributes
    validates :primary_first_name, presence: true, allow_blank: false
    validates :primary_last_name, presence: true, allow_blank: false
    validate :dependents_attributes_required_fields

    def initialize(intake, params = {})
      @intake = intake
      super(params)
    end

    def dependents
      dependents_attributes = attributes_for(:intake)[:dependents_attributes]
      dependents_attributes&.each do |k, v|
        next if v["_destroy"] == "1"

        v.delete :_destroy # delete falsey _destroy value on reload to initialize dependent again
        @intake.dependents.new formatted_dependent_attrs(v)
      end
      @intake.dependents
    end

    def self.from_intake(intake, params = {})
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(intake, existing_attributes(intake).slice(*attribute_keys).merge(params))
    end

    def save
      return false unless valid?

      updated_attributes = attributes_for(:intake).reject { |_k, v| v.nil? }
      updated_attributes[:dependents_attributes]&.map do |k, v|
        { k => formatted_dependent_attrs(v) }
      end
      @intake.update(updated_attributes)
    end

    def self.permitted_params
      client_intake_attributes = ClientIntakeForm.attribute_names
      client_intake_attributes.delete(:dependents_attributes)
      client_intake_attributes.push({ dependents_attributes: {} })
      client_intake_attributes
    end

    private

    def dependents_attributes_required_fields
      empty_fields = []
      attributes_for(:intake)[:dependents_attributes]&.each do |_, v|
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