module Hub
  class Update13614cFormPage2 < Form
    include FormAttributes

    set_attributes_for :intake,
                       :had_wages,
                       :job_count,
                       :had_tips,
                       :had_interest_income,
                       :had_local_tax_refund,
                       :received_alimony,
                       :had_self_employment_income,
                       :had_asset_sale_income,
                       :had_disability_income,
                       :had_retirement_income,
                       :had_unemployment_income,
                       :had_social_security_income,
                       :had_rental_income,
                       :had_other_income,
                       :paid_alimony,
                       :paid_retirement_contributions

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

    # override what's in FormAttribute to prevent nils (which
    # are causing database errors)
    def attributes_for(model)
      self.class.scoped_attributes[model].reduce({}) do |hash, attribute_name|
        v = send(attribute_name)
        hash[attribute_name] = v ? v : 'unfilled'
        hash
      end
    end

    def save
      return false unless valid?

      @client.intake.update(attributes_for(:intake))
      @client.touch(:last_13614c_update_at)
    end
  end
end
