module Ctc
  class ClaimEitcForm < QuestionsForm
    set_attributes_for :intake, :claim_eitc

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
