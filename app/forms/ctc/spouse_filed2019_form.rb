module Ctc
  class SpouseFiled2019Form < QuestionsForm
    set_attributes_for :intake, :spouse_filed_2019

    validates_presence_of :spouse_filed_2019

    def save
      attributes = attributes_for(:intake)
      attributes[:spouse_prior_year_agi_amount] = 1 if ["filed_non_filer_separate", "filed_non_filer_joint"].include?(spouse_filed_2019)
      @intake.update(attributes)
    end
  end
end
