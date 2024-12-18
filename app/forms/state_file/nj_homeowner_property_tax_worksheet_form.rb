module StateFile
  class NjHomeownerPropertyTaxWorksheetForm < QuestionsForm
    set_attributes_for :intake,
                       :property_tax_paid

    validates :property_tax_paid, presence: true
    validates_numericality_of :property_tax_paid, message: I18n.t("validators.not_a_number"), if: -> { property_tax_paid.present? }
    validates :property_tax_paid, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { property_tax_paid.present? }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end