module Hub
  class Update13614cFormPage1 < ClientForm
    set_attributes_for :intake,
                       :primary_first_name,
                       :primary_last_name,
                       :primary_middle_initial,
                       :married,
                       :separated,
                       :widowed,
                       :lived_with_spouse,
                       :divorced,
                       :divorced_year,
                       :separated_year,
                       :widowed_year,
                       :claimed_by_another,
                       :issued_identity_pin,
                       :email_address,
                       :phone_number,
                       :had_disability,
                       :was_full_time_student,
                       :primary_birth_date_year,
                       :primary_birth_date_month,
                       :primary_birth_date_day,
                       :primary_job_title,
                       :primary_lived_or_worked_in_two_or_more_states,
                       :primary_owned_or_held_any_digital_currencies,
                       :primary_us_citizen,
                       :street_address,
                       :city,
                       :state,
                       :zip_code,
                       :street_address2,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_middle_initial,
                       :spouse_owned_or_held_any_digital_currencies,
                       :was_blind,
                       :spouse_was_blind,
                       :spouse_birth_date_year,
                       :spouse_birth_date_month,
                       :spouse_birth_date_day,
                       :spouse_had_disability,
                       :spouse_job_title,
                       :spouse_phone_number,
                       :spouse_was_full_time_student,
                       :spouse_us_citizen,
                       :never_married,
                       :got_married_during_tax_year

    attr_accessor :client

    def initialize(client, params = {})
      @client = client
      super(params)
    end

    def self.from_client(client)
      intake = client.intake
      attribute_keys = Attributes.new(attribute_names).to_sym
      new(client, existing_attributes(intake).slice(*attribute_keys))
    end

    def self.existing_attributes(intake)
      result = super
      result[:never_married] = result.delete(:ever_married) == 'yes' ? 'no' : 'yes'
      if result[:primary_birth_date].present?
        birth_date = result[:primary_birth_date]
        result.merge!(
          primary_birth_date_year: birth_date.year,
          primary_birth_date_month: birth_date.month,
          primary_birth_date_day: birth_date.day,
        )
        end
      if result[:spouse_birth_date].present?
        birth_date = result[:spouse_birth_date]
        result.merge!(
          spouse_birth_date_year: birth_date.year,
          spouse_birth_date_month: birth_date.month,
          spouse_birth_date_day: birth_date.day,
        )
      end
      result
    end

    def save
      return false unless valid?

      modified_attributes = attributes_for(:intake)
                              .except(:primary_birth_date_year, :primary_birth_date_month, :primary_birth_date_day, :spouse_birth_date_year, :spouse_birth_date_month, :spouse_birth_date_day)
                              .merge(
                                primary_birth_date: parse_date_params(primary_birth_date_year, primary_birth_date_month, primary_birth_date_day),
                                spouse_birth_date: parse_date_params(spouse_birth_date_year, spouse_birth_date_month, spouse_birth_date_day),
                              )
      modified_attributes[:ever_married] = modified_attributes.delete(:never_married) == "yes" ? "no" : "yes"
      modified_attributes[:dependents_attributes] = formatted_dependents_attributes

      @client.intake.update(modified_attributes)
      @client.touch(:last_13614c_update_at)
    end
  end
end
