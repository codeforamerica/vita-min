module Ctc
  class SpouseAgi2019Form < QuestionsForm
    set_attributes_for :intake, :spouse_prior_year_agi_amount

    def save
      @intake.update!(attributes_for(:intake))
    end
  end
end