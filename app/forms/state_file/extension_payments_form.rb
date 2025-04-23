module StateFile
  class ExtensionPaymentsForm < QuestionsForm
    set_attributes_for :intake, :paid_extension_payments, :extension_payments_amount
    validates :paid_extension_payments, inclusion: { in: %w[yes no], message: :blank }
    validates :extension_payments_amount,
              positive_money_field: true,
              if: -> { paid_extension_payments == "yes" }

    def save
      if paid_extension_payments == "no"
        @intake.update(paid_extension_payments: "no", extension_payments_amount: 0)
      else
        @intake.update(attributes_for(:intake))
      end
    end

    def error_msg_if_blank_or_zero
      I18n.t(
        "state_file.questions.extension_payments.#{@intake.state_code}.payment_validation_message",
        default: I18n.t("state_file.questions.extension_payments.default_payment_validation_message")
      )
    end
  end
end