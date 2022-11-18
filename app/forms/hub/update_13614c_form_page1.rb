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
                       # :sms_phone_number, TODO: verify we don't need this
                       :was_full_time_student,
                       :primary_birth_date,
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
                       :spouse_was_full_time_student

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

    def save
      return false unless valid?

      @client.intake.update(attributes_for(:intake).merge(dependents_attributes: formatted_dependents_attributes))
    end
  end
end
