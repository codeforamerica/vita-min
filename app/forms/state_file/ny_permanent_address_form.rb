module StateFile
  class NyPermanentAddressForm < QuestionsForm
    set_attributes_for :intake,
                       :confirmed_permanent_address,
                       :permanent_apartment,
                       :permanent_street,
                       :permanent_city,
                       :permanent_zip

    validates :confirmed_permanent_address, presence: true
    validates :permanent_street, presence: true, if: -> { confirmed_permanent_address == "no" }
    validates :permanent_city, presence: true, if: -> { confirmed_permanent_address == "no" }
    validates :permanent_zip, presence: true, if: -> { confirmed_permanent_address == "no" }

    def initialize(intake = nil, params = nil)
      if params[:confirmed_permanent_address] == "yes"
        [:permanent_apartment, :permanent_street, :permanent_city, :permanent_zip].each do |param|
          params[param] = ""
        end
      end
      super(intake, params)
    end

    def save
      attributes_from_direct_file = confirmed_permanent_address == "yes" ?
                                {
                                  permanent_apartment: @intake.direct_file_data.mailing_apartment,
                                  permanent_city: @intake.direct_file_data.mailing_city,
                                  permanent_street: @intake.direct_file_data.mailing_street,
                                  permanent_zip: @intake.direct_file_data.mailing_zip,
                                } : {}

      @intake.update(attributes_for(:intake).merge(attributes_from_direct_file))
    end
  end
end