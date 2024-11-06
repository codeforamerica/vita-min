module StateFile
  class MdPermanentAddressForm < QuestionsForm
    set_attributes_for :intake,
                       :confirmed_permanent_address,
                       :permanent_street,
                       :permanent_apartment,
                       :permanent_city,
                       :permanent_zip,
                       :permanent_address_outside_md

    validates :confirmed_permanent_address, presence: true
    validates :permanent_street, presence: true, irs_street_address_type: { maximum: nil }, if: -> { confirmed_permanent_address == "no" }
    validates :permanent_apartment, irs_street_address_type: { maximum: nil }
    validates :permanent_city, presence: true, irs_street_address_type: { maximum: nil }, if: -> { confirmed_permanent_address == "no" }
    validates :permanent_zip, presence: true, zip_code: { zip_code_lengths: [5, 9, 12].freeze }, if: -> { confirmed_permanent_address == "no" }

    def initialize(intake = nil, params = nil)
      if params[:confirmed_permanent_address] == "yes"
        [:permanent_street, :permanent_apartment, :permanent_city, :permanent_zip].each do |param|
          params[param] = ""
        end
      end
      super(intake, params)
    end

    def save
      attributes_from_direct_file = confirmed_permanent_address == "yes" ?
                                      {
                                        permanent_city: @intake.direct_file_data.mailing_city,
                                        permanent_street: @intake.direct_file_data.mailing_street,
                                        permanent_apartment: @intake.direct_file_data.mailing_apartment,
                                        permanent_zip: @intake.direct_file_data.mailing_zip,
                                      } : {}
      attributes_from_direct_file[:permanent_address_outside_md] = @intake.direct_file_data.mailing_state != 'MD' && confirmed_permanent_address == "yes" ? "yes" : "no"
      attributes_from_form = attributes_for(:intake).except(:permanent_zip).merge({permanent_zip: permanent_zip&.delete('-')})
      @intake.update(attributes_from_form.merge(attributes_from_direct_file))
    end
  end
end
