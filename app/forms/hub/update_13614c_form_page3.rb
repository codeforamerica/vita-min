module Hub
  class Update13614cFormPage3 < Form
    include FormAttributes

    set_attributes_for :intake,
                       :receive_written_communication,
                       :preferred_written_language,
                       :refund_payment_method,
                       :savings_purchase_bond,
                       :savings_split_refund,
                       :balance_pay_from_bank,
                       :had_disaster_loss,
                       :received_irs_letter,
                       :presidential_campaign_fund_donation,
                       :had_disaster_loss_where,
                       :register_to_vote,
                       :demographic_english_conversation,
                       :demographic_english_reading,
                       :demographic_disability,
                       :demographic_veteran,
                       :demographic_primary_american_indian_alaska_native,
                       :demographic_primary_asian,
                       :demographic_primary_black_african_american,
                       :demographic_primary_native_hawaiian_pacific_islander,
                       :demographic_primary_white,
                       :demographic_primary_prefer_not_to_answer_race,
                       :demographic_spouse_american_indian_alaska_native,
                       :demographic_spouse_asian,
                       :demographic_spouse_black_african_american,
                       :demographic_spouse_native_hawaiian_pacific_islander,
                       :demographic_spouse_white,
                       :demographic_spouse_prefer_not_to_answer_race,
                       :demographic_primary_ethnicity,
                       :demographic_spouse_ethnicity

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

    def self.existing_attributes(intake)
      intake.preferred_written_language = intake.preferred_written_language_string
      super
    end
  end
end
