module StateFile
  class NjHomeownerPropertyTaxForm < QuestionsForm
    set_attributes_for :intake,
                       :property_tax_paid

    validates :property_tax_paid, presence: true
    validates_numericality_of :property_tax_paid, only_integer: true, message: :round_to_whole_number, if: -> { property_tax_paid.present? }
    validates :property_tax_paid, presence: true, allow_blank: false, numericality: { greater_than_or_equal_to: 1 }, if: -> { property_tax_paid.present? }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end