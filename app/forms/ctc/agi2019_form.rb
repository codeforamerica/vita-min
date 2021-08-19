module Ctc
  class Agi2019Form < QuestionsForm
    set_attributes_for :intake, :primary_prior_year_agi_amount

    def save
      @intake.update!(attributes_for(:intake))
    end
  end
end