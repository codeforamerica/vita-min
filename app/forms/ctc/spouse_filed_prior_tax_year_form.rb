module Ctc
  class SpouseFiledPriorTaxYearForm < QuestionsForm
    set_attributes_for :intake, :spouse_filed_prior_tax_year

    validates_presence_of :spouse_filed_prior_tax_year

    def save
      attributes = attributes_for(:intake)
      attributes[:spouse_prior_year_agi_amount] = 1 if %w[
        filed_non_filer_separate
        filed_non_filer_joint
      ].include?(spouse_filed_prior_tax_year)
      @intake.update(attributes)
    end
  end
end
