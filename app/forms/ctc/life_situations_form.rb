module Ctc
  class LifeSituationsForm < QuestionsForm
    set_attributes_for :eligibility, :can_be_claimed_as_dependent

    def save; end

    def can_be_claimed_as_a_dependent?
      can_be_claimed_as_dependent == "yes"
    end
  end
end