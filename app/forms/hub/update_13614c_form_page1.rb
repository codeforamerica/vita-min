module Hub
  class Update13614cFormPage1 < ClientForm
    set_attributes_for Intake::GyrIntake,
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
                       :multiple_states,
                       :primary_owned_or_held_any_digital_currencies,
                       :primary_us_citizen,
                       :primary_visa,
                       :street_address,
                       :city,
                       :state,
                       :zip_code,
                       :street_address2,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_middle_initial,
                       :spouse_owned_or_held_any_digital_currencies,
                       :spouse_issued_identity_pin,
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
                       :spouse_visa,
                       :never_married,
                       :married_for_all_of_tax_year,
                       :receive_written_communication,
                       :preferred_written_language,
                       :presidential_campaign_fund_donation,
                       :refund_direct_deposit,
                       :refund_check_by_mail,
                       :savings_split_refund,
                       :refund_other_cb,
                       :refund_other,
                       :balance_pay_from_bank,
                       :register_to_vote

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

      # Intake flow assigns 2-char language code to preferred_written_language
      # but here we switch to the person-readable name of the language upon
      # first loading of hub editable 14-c page 1. (And upon a save, the
      # string, possibly altered by the user, also is what will get saved into the
      # field.) See the method GyrIntake#preferred_written_language_string for
      # more insight. (Jan. 2025)
      result.merge!(preferred_written_language: intake.preferred_written_language_string)

      result
    end

    def save
      return false unless valid?

      modified_attributes = attributes_for(Intake::GyrIntake)
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
