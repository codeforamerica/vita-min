module Ctc
  class FiledPriorTaxYearForm < QuestionsForm
    set_attributes_for :intake, :filed_prior_tax_year

    validates_presence_of :filed_prior_tax_year

    def save
      attributes = attributes_for(:intake)
      attributes[:primary_prior_year_agi_amount] = 1 if filed_prior_tax_year == "filed_non_filer"
      @intake.update(attributes)
    end

    def filed_prior_tax_year?
      filed_prior_tax_year != "did_not_file"
    end
  end
end