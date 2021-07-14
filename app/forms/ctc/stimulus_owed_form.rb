module Ctc
  class StimulusOwedForm < QuestionsForm
    set_attributes_for :intake, :claim_owed_stimulus_money

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end