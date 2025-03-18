module StateFile
  class NjEstimatedTaxPaymentsForm < QuestionsForm
    set_attributes_for :intake,
                       :has_estimated_payments,
                       :estimated_tax_payments,
                       :overpayments

    validates :has_estimated_payments, presence: true
    validates_numericality_of :estimated_tax_payments, message: I18n.t("validators.not_a_number"), if: -> { estimated_tax_payments.present? }
    validates_numericality_of :overpayments, message: I18n.t("validators.not_a_number"), if: -> { overpayments.present? }
    validates :estimated_tax_payments, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { has_estimated_payments == "yes" }
    validates :overpayments, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { has_estimated_payments == "yes" }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end