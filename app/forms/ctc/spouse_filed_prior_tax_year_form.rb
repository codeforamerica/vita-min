module Ctc
  class SpouseFiledPriorTaxYearForm < QuestionsForm
    set_attributes_for :intake, :spouse_filed_prior_tax_year

    validates_presence_of :spouse_filed_prior_tax_year

    def save
      attributes = attributes_for(:intake)
      attributes[:spouse_prior_year_agi_amount] = 1 if %w[
        filed_non_filer_separate
      ].include?(spouse_filed_prior_tax_year)
      attributes[:spouse_prior_year_agi_amount] = 1 if %w[
        filed_together
      ].include?(spouse_filed_prior_tax_year) && @intake.filed_prior_tax_year_filed_non_filer?
      @intake.update(attributes)
    end
  end
end
