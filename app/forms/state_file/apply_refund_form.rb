module StateFile
  class ApplyRefundForm < QuestionsForm
    set_attributes_for :intake, :paid_prior_year_refund_payments, :prior_year_refund_payments_amount
    validates :paid_prior_year_refund_payments, inclusion: { in: %w[yes no], message: :blank }
    validates :prior_year_refund_payments_amount,
              positive_money_field: true,
              if: -> { paid_prior_year_refund_payments == "yes" }

    def save
      if paid_prior_year_refund_payments == "no"
        @intake.update(paid_prior_year_refund_payments: "no", prior_year_refund_payments_amount: 0)
      else
        @intake.update(attributes_for(:intake))
      end
    end

    def error_msg_if_blank_or_zero
      I18n.t("state_file.questions.apply_refund.edit.payments_amount_validation")
    end
  end
end