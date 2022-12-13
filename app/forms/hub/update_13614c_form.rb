module Hub
  class Update13614cForm < ClientForm
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
                       :primary_birth_date,
                       :primary_job_title,
                       :primary_us_citizen,
                       :street_address,
                       :city,
                       :state,
                       :zip_code,
                       :street_address2,
                       :spouse_first_name,
                       :spouse_last_name,
                       :spouse_middle_initial,
                       :was_blind,
                       :spouse_was_blind,
                       :spouse_birth_date,
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
      result
    end

    def save
      return false unless valid?

      modified_attributes = attributes_for(:intake)
      modified_attributes[:ever_married] = modified_attributes.delete(:never_married) == "yes" ? "no" : "yes"
      modified_attributes[:dependents_attributes] = formatted_dependents_attributes

      @client.intake.update(modified_attributes)
      @client.touch(:last_13614c_update_at)
    end
  end
end
