module Ctc
  class Filed2019Form < QuestionsForm
    set_attributes_for :intake, :filed_2019

    validates_presence_of :filed_2019

    def save
      attributes = attributes_for(:intake)
      attributes[:primary_prior_year_agi_amount] = 1 if filed_2019 == "filed_non_filer"
      @intake.update(attributes)
    end

    def filed_2019?
      filed_2019 != "did_not_file"
    end
  end
end