module Ctc
  class LifeSituations2020Form < QuestionsForm
    set_attributes_for :intake, :cannot_claim_me_as_a_dependent, :member_of_the_armed_forces

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end