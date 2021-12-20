module Ctc
  class SpousePriorTaxYearAgiForm < QuestionsForm
    set_attributes_for :intake, :spouse_prior_year_agi_amount

    validates :spouse_prior_year_agi_amount, gyr_numericality: true, if: :not_blank?

    def save
      @intake.update!(attributes_for(:intake))
    end

    def not_blank?
      attributes_for(:intake)[:spouse_prior_year_agi_amount].present?
    end
  end
end
