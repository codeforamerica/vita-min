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

      validates :employer_ein, presence: true, format: { with: /\A[0-9]{9}\z/, message: ->(*_args) { I18n.t('validators.ein') } }
      validates :employer_name, presence: true
      validates :standard_or_non_standard_code, presence: true, inclusion: { in: %w(S N) }
      validates :employer_city, presence: true, format: { with: /\A([A-Za-z] ?)*[A-Za-z]\z/, message: -> (*_args) { I18n.t('validators.alpha') }}
      validates :employer_state, presence: true, inclusion: { in: States.keys }
      validates :employer_zip_code, presence: true, format: { with: /\A[0-9]{5}(([0-9]{4})|([0-9]{7}))?\z/, message: -> (*_args) { I18n.t('validators.zip_code_with_optional_extra_digits') } }
      validates :employer_street_address, irs_street_address_type: true
      validates :employer_street_address2, irs_street_address_type: true, allow_blank: true

      before_validation do
        self.employer_ein = employer_ein&.delete('-')
      end
    end
  end
end
