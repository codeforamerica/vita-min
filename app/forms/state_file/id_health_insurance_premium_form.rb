module StateFile
  class IdHealthInsurancePremiumForm < QuestionsForm
    set_attributes_for :intake, :has_health_insurance_premium, :health_insurance_paid_amount

    validates :has_health_insurance_premium, inclusion: { in: %w[yes no], message: :blank }
    validates :health_insurance_paid_amount,
      presence: true,
      numericality: {
        allow_blank: true,
        greater_than_or_equal_to: 0,
        message: I18n.t("validators.not_a_number")
      },
      if: -> { has_health_insurance_premium == "yes" }

    def save
      attributes_to_save = attributes_for(:intake)
      attributes_to_save[:health_insurance_paid_amount] = nil if has_health_insurance_premium == "no"
      @intake.update!(attributes_to_save)
    end
  end
end