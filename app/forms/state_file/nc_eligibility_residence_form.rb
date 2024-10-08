module StateFile
  class NcEligibilityResidenceForm < QuestionsForm
    set_attributes_for :intake, :eligibility_lived_in_state

    validates :eligibility_lived_in_state, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end