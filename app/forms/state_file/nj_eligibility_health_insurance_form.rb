module StateFile
  class NjEligibilityHealthInsuranceForm < QuestionsForm
    set_attributes_for :intake, :eligibility_all_members_health_insurance
    attr_accessor :dependents_attributes
    delegate :dependents, to: :intake

    validates :eligibility_all_members_health_insurance, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end