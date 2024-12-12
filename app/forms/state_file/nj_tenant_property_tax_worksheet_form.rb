module StateFile
  class NjTenantPropertyTaxWorksheetForm < QuestionsForm
    set_attributes_for :intake,
                       :rent_paid

    validates_numericality_of :rent_paid, message: I18n.t("validators.not_a_number"), if: -> { rent_paid.present? }
    validates :rent_paid, presence: true, numericality: { greater_than_or_equal_to: 1 }, if: -> { rent_paid.present? }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end