module Hub
  class ClientForm < Form
    include FormAttributes
    # These are only really here for tests,
    # every leaf class of ClientForm has to define
    # their full set of attributes
    set_attributes_for :intake,
        :sms_phone_number,
        :phone_number,
        :preferred_name,
        :primary_first_name,
        :primary_last_name,
        :spouse_first_name,
        :spouse_last_name,
        :email_address,
        :sms_notification_opt_in,
        :email_notification_opt_in,
        :signature_method

    before_validation do
      self.sms_phone_number = PhoneParser.normalize(sms_phone_number)
      self.phone_number = PhoneParser.normalize(phone_number)
      self.preferred_name = preferred_name.presence || "#{primary_first_name} #{primary_last_name}"

      if dependents_attributes
        dependents_attributes.each do |_k, attrs|
          attrs[:ssn]&.remove!(/\D/)
          attrs[:ssn_confirmation]&.remove!(/\D/)
        end
      end
    end

    validates :email_address, 'valid_email_2/email': true
    validates :phone_number, allow_blank: true, e164_phone: true
    validates :sms_phone_number, allow_blank: true, e164_phone: true
    validates :primary_first_name, presence: true, allow_blank: false, legal_name: true
    validates :primary_last_name, presence: true, allow_blank: false, legal_name: true
    validates :spouse_first_name, legal_name: true
    validates :spouse_last_name, legal_name: true
    validate :contact_method_if_opted_in
    validate :at_least_one_contact_method_if_signature_method_online

    attr_accessor :dependents_attributes

    def valid?
      form_valid = super
      dependents_valid = dependents.map { |d| d.valid?(dependent_validation_context) }
      form_valid && !dependents_valid.include?(false)
    end

    def dependents
      @_dependents ||= begin
        unless @dependents_attributes.present?
          return @client.present? ? @client.intake.dependents : Dependent.none
        end

        intake = @client&.intake.dup || default_attributes[:type].constantize.new
        @dependents_attributes&.map do |_, v|
          next if v["_destroy"] == "1"

          v.delete :_destroy # delete falsey _destroy value on reload to initialize dependent again
          dependent = intake.dependents.find { |i| i.id == v[:id].to_i } || intake.dependents.new
          dependent.assign_attributes(formatted_dependent_attrs(v))
        end.compact
        intake.dependents
      end
    end

    private

    def self.permitted_params
      attribute_names.push( { dependents_attributes: {}, tax_returns_attributes: {} })
    end

    def dependent_validation_context
      nil
    end

    def at_least_one_contact_method_if_signature_method_online
      return if signature_method != "online"
      return if email_notification_opt_in == "yes" && email_address.present?
      return if sms_notification_opt_in == "yes" && sms_phone_number.present?

      errors.add(:email_address, I18n.t("forms.errors.hub.communication_opt_in"))
      errors.add(:sms_phone_number, I18n.t("forms.errors.hub.communication_opt_in"))
    end

    def contact_method_if_opted_in
      if email_notification_opt_in == "yes" && email_address.blank?
        errors.add(:email_address, I18n.t("forms.errors.hub.contact_method_required", attribute: "email"))
      end
      if sms_notification_opt_in == "yes" && sms_phone_number.blank?
        errors.add(:sms_phone_number, I18n.t("forms.errors.hub.contact_method_required", attribute: "cell phone number"))
      end
    end

    def formatted_dependents_attributes
      @dependents_attributes&.map { |k, v| [k, formatted_dependent_attrs(v)] }.to_h
    end

    def formatted_dependent_attrs(attrs)
      if attrs[:birth_date_month] && attrs[:birth_date_month] && attrs[:birth_date_year]
        attrs[:birth_date] = "#{attrs[:birth_date_year]}-#{attrs[:birth_date_month]}-#{attrs[:birth_date_day]}"
      end
      attrs[:ssn_confirmation] = attrs[:ssn]
      attrs.except!(:birth_date_month, :birth_date_day, :birth_date_year)
    end
  end
end
