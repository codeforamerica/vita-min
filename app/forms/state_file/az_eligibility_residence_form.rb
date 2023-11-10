module StateFile
  class AzEligibilityResidenceForm < QuestionsForm
    set_attributes_for :intake, :eligibility_lived_in_state, :eligibility_married_filing_separately

    validates :eligibility_lived_in_state, presence: true
    validates :eligibility_married_filing_separately, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end