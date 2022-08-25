module Ctc
  module W2s
    class EmployerInfoForm < W2Form
      set_attributes_for(
        :w2,
        :employer_ein,
        :employer_name,
        :employer_street_address,
        :employer_street_address2,
        :employer_city,
        :employer_state,
        :employer_zip_code,
        :standard_or_non_standard_code
      )

      validates :employer_street_address, irs_street_address_type: true
      validates :employer_street_address2, irs_street_address_type: true, allow_blank: true
    end
  end
end
