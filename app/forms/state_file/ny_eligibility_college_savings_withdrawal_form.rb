module StateFile
  class NyEligibilityCollegeSavingsWithdrawalForm < QuestionsForm
    set_attributes_for :intake, :eligibility_withdrew_529

    validates :eligibility_withdrew_529, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end