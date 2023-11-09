module StateFile
  class NyEligibilityResidenceForm < QuestionsForm
    set_attributes_for :intake, :eligibility_lived_in_state, :eligibility_yonkers

    validates :eligibility_lived_in_state, presence: true
    validates :eligibility_yonkers, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end