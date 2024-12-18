module StateFile
  class IdEligibilityResidenceForm < QuestionsForm
    set_attributes_for :intake, :eligibility_withdrew_msa_fthb, :eligibility_emergency_rental_assistance

    validates :eligibility_withdrew_msa_fthb, presence: true
    validates :eligibility_emergency_rental_assistance, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end