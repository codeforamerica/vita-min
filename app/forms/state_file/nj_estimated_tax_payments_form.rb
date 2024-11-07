module StateFile
  class NjEstimatedTaxPaymentsForm < QuestionsForm
    set_attributes_for :intake,
                       :estimated_tax_payments

    validates_numericality_of :estimated_tax_payments, message: I18n.t("validators.not_a_number"), if: -> { estimated_tax_payments.present? }
    validates :estimated_tax_payments, presence: true, allow_blank: true, numericality: { greater_than_or_equal_to: 0 }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end