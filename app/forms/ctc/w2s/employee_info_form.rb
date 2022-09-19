module Ctc
  module W2s
    class EmployeeInfoForm < W2Form
      set_attributes_for(
        :w2,
        :wages_amount,
        :federal_income_tax_withheld,
        :employee_street_address,
        :employee_street_address2,
        :employee_city,
        :employee_state,
        :employee_zip_code,
        :employee
      )

      validates :employee_street_address, irs_street_address_type: true
      validates :employee_street_address2, irs_street_address_type: true, allow_blank: true
      validates :wages_amount, gyr_numericality: true, presence: true
      validates :federal_income_tax_withheld, gyr_numericality: true, presence: true
      validates :employee_city, presence: true, format: { with: /\A([A-Za-z] ?)*[A-Za-z]\z/, message: -> (*_args) { I18n.t('validators.alpha') }}
      validates :employee_state, presence: true, inclusion: { in: States.keys }
      validates :employee_zip_code, presence: true, format: { with: /\A[0-9]{5}(([0-9]{4})|([0-9]{7}))?\z/, message: -> (*_args) { I18n.t('validators.zip_code_with_optional_extra_digits') } }
    end
  end
end
