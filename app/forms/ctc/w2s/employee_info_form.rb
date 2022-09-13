module Ctc
  module W2s
    class EmployeeInfoForm < W2Form
      set_attributes_for(
        :w2,
        :legal_first_name,
        :legal_middle_initial,
        :legal_last_name,
        :suffix,
        :employee_ssn,
        :wages_amount,
        :federal_income_tax_withheld,
        :employee_street_address,
        :employee_street_address2,
        :employee_city,
        :employee_state,
        :employee_zip_code
      )
      set_attributes_for(:confirmation, :employee_ssn_confirmation)

      validates :employee_street_address, irs_street_address_type: true
      validates :employee_street_address2, irs_street_address_type: true, allow_blank: true
      validates :legal_first_name, presence: true, legal_name: true
      validates :legal_middle_initial, legal_name: true
      validates :legal_last_name, presence: true, legal_name: true
      validates :wages_amount, gyr_numericality: true, presence: true
      validates :federal_income_tax_withheld, gyr_numericality: true, presence: true
      validates :employee_city, presence: true, format: { with: /\A([A-Za-z] ?)*[A-Za-z]\z/, message: -> (*_args) { I18n.t('validators.alpha') }}
      validates :employee_state, presence: true, inclusion: { in: States.keys }
      validates :employee_zip_code, presence: true, format: { with: /\A[0-9]{5}(([0-9]{4})|([0-9]{7}))?\z/, message: -> (*_args) { I18n.t('validators.zip_code_with_optional_extra_digits') } }

      validates :employee_ssn, social_security_number: true

      with_options if: -> { (employee_ssn.present? && employee_ssn.remove(/\D/) != @w2.employee_ssn) || employee_ssn_confirmation.present? } do
        validates :employee_ssn, confirmation: true
        validates :employee_ssn_confirmation, presence: true
      end
    end
  end
end
