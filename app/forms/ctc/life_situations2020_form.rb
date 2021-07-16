module Ctc
  class LifeSituations2020Form < QuestionsForm
    set_attributes_for :intake, :cannot_claim_me_as_a_dependent, :primary_member_of_the_armed_forces

    def save
      @intake.update(attributes_for(:intake))
    end

    def cannot_be_claimed_as_dependent?
      cannot_claim_me_as_a_dependent == "no"
    end
  end
end