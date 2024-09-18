module StateFile
  class NcEligibilityOutOfStateIncomeForm < QuestionsForm
    set_attributes_for :intake, :eligibility_out_of_state_income, :eligibility_withdrew_529

    validates :eligibility_out_of_state_income, presence: true
    validates :eligibility_withdrew_529, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end