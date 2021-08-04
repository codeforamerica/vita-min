module Ctc
  class PrimaryActiveArmedForcesForm < QuestionsForm
    set_attributes_for :intake, :primary_active_armed_forces

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end