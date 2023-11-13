module StateFile
  class AzEligibilityOutOfStateIncomeForm < QuestionsForm
    set_attributes_for :intake, :eligibility_out_of_state_income, :eligibility_529_for_non_qual_expense

    validates :eligibility_out_of_state_income, presence: true
    validates :eligibility_529_for_non_qual_expense, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end