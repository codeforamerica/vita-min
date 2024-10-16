module StateFile
  class MdEligibilityFilingStatusForm < QuestionsForm
    set_attributes_for :intake, :eligibility_filing_status_mfj, :eligibility_homebuyer_withdrawal, :eligibility_homebuyer_withdrawal_mfj, :eligibility_home_different_areas

    validates :eligibility_filing_status_mfj, presence: true
    validates :eligibility_homebuyer_withdrawal_mfj, presence: true, if: -> { eligibility_filing_status_mfj == "yes" }
    validates :eligibility_homebuyer_withdrawal, presence: true, unless: -> { eligibility_filing_status_mfj == "yes" }
    validates :eligibility_home_different_areas, presence: true, if: -> { eligibility_filing_status_mfj == "yes" }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
