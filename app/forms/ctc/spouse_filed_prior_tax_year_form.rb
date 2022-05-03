module Ctc
  class SpouseFiledPriorTaxYearForm < QuestionsForm
    set_attributes_for :intake, :spouse_filed_prior_tax_year

    validates_presence_of :spouse_filed_prior_tax_year

    def save
      attributes = attributes_for(:intake)
      @intake.update(attributes)
    end
  end
end
