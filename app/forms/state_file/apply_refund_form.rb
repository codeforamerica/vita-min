module StateFile
  class ApplyRefundForm < QuestionsForm
    set_attributes_for :intake, :paid_prior_year_refund_payments, :prior_year_refund_payments_amount
    validates :paid_prior_year_refund_payments, inclusion: { in: %w[yes no], message: :blank }
    validates :prior_year_refund_payments_amount,
              presence: true,
              numericality: {
                allow_blank: false,
                greater_than: 0,
                message: I18n.t("validators.not_a_number")
              },
              if: -> { paid_prior_year_refund_payments == "yes" }

    def save
      if paid_prior_year_refund_payments == "no"
        @intake.update(paid_prior_year_refund_payments: "no", prior_year_refund_payments_amount: 0)
      else
        @intake.update(attributes_for(:intake))
      end
    end
  end
end