module StateFile
  class AzExtensionPaymentsForm < QuestionsForm
    set_attributes_for :intake, :paid_extension_payments, :extension_payments_amount
    validates :paid_extension_payments, inclusion: { in: %w[yes no], message: :blank }
    validates :extension_payments_amount,
              presence: true,
              numericality: {
                allow_blank: false,
                greater_than_or_equal_to: 0,
                message: I18n.t("validators.not_a_number")
              },
              if: -> { paid_extension_payments == "yes" }

    def save
      if paid_extension_payments == "no"
        @intake.update(paid_extension_payments: "no", extension_payments_amount: nil)
      else
        @intake.update(attributes_for(:intake))
      end
    end
  end
end