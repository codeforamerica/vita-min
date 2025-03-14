module StateFile
  class NjOverpaymentsForm < QuestionsForm
    set_attributes_for :intake,
                       :has_overpayments,
                       :overpayments

    validates :has_overpayments, presence: true
    validates_numericality_of :overpayments, message: I18n.t("validators.not_a_number"), if: -> { overpayments.present? }
    validates :overpayments, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: -> { has_overpayments == "yes" }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end