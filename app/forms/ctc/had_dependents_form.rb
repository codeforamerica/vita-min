module Ctc
  class HadDependentsForm < QuestionsForm
    set_attributes_for :intake, :had_dependents

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
