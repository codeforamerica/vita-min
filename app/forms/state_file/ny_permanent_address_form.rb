module StateFile
  class NyPermanentAddressForm < QuestionsForm
    set_attributes_for :intake, :confirmed_permanent_address

    def save
      additional_attributes = confirmed_permanent_address == "yes" ?
        {
          permanent_apartment: @intake.direct_file_data.mailing_apartment,
          permanent_city: @intake.direct_file_data.mailing_city,
          permanent_street: @intake.direct_file_data.mailing_street,
          permanent_zip: @intake.direct_file_data.mailing_zip,
        } : {}

      @intake.update(attributes_for(:intake).merge(additional_attributes))
    end
  end
end