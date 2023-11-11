module StateFile
  class NyEligibilityOutOfStateIncomeForm < QuestionsForm
    set_attributes_for :intake, :eligibility_out_of_state_income, :eligibility_part_year_nyc_resident

    validates :eligibility_out_of_state_income, presence: true
    validates :eligibility_part_year_nyc_resident, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end