module StateFile
  class FederalExtensionPaymentsForm < QuestionsForm
    set_attributes_for :intake, :paid_federal_extension_payments, :federal_extension_payments_amount
    validates :paid_federal_extension_payments, inclusion: { in: %w[yes no], message: :blank }
    validates :federal_extension_payments_amount,
              presence: true,
              numericality: {
                allow_blank: false,
                greater_than_or_equal_to: 0,
                message: I18n.t("validators.not_a_number")
              },
              if: -> { paid_federal_extension_payments == "yes" }

    def save

      attributes = attributes_for(:intake)
      if paid_federal_extension_payments == "no"
        attributes = attributes.merge({federal_extension_payments_amount: 0})
      end
      @intake.update(attributes)
    end
  end
end
