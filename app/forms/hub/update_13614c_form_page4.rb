module Hub
  class Update13614cFormPage4 < Form
    include FormAttributes

    set_attributes_for :intake,
                       :demographic_english_conversation,
                       :demographic_english_reading,
                       :demographic_disability,
                       :demographic_veteran,
                       :demographic_primary_american_indian_alaska_native,
                       :demographic_primary_asian,
                       :demographic_primary_black_african_american,
                       :demographic_primary_mena,
                       :demographic_primary_native_hawaiian_pacific_islander,
                       :demographic_primary_white,
                       :demographic_primary_prefer_not_to_answer_race,
                       :demographic_spouse_american_indian_alaska_native,
                       :demographic_spouse_asian,
                       :demographic_spouse_black_african_american,
                       :demographic_spouse_mena,
                       :demographic_spouse_native_hawaiian_pacific_islander,
                       :demographic_spouse_white

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
      @client.intake.update(attributes_for(:intake))
      @client.touch(:last_13614c_update_at)
    end
  end
end

