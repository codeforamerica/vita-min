module StateFile
  class NjRetirementWarningForm < QuestionsForm
    set_attributes_for :intake, :eligibility_retirement_warning_continue

    validates :eligibility_retirement_warning_continue, presence: true
    
    def save
      @intake.update(attributes_for(:intake))
    end
  end
end