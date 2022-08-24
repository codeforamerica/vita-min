module Ctc
  module W2s
    class EmployeeInfoForm < W2Form
      set_attributes_for(
        :w2,
        :legal_first_name,
        :legal_middle_initial,
        :legal_last_name,
        :employee_ssn,
        :wages_amount,
        :federal_income_tax_withheld,
        :employee_street_address,
        :employee_street_address2,
        :employee_city,
        :employee_state,
        :employee_zip_code
      )

      validates :employee_street_address, irs_street_address_type: true
      validates :employee_street_address2, irs_street_address_type: true, allow_blank: true
    end
  end
end
