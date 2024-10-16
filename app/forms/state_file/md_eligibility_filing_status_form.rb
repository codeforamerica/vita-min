module StateFile
  class MdEligibilityFilingStatusForm < QuestionsForm
    set_attributes_for :intake, :eligibility_filing_status_mfj, :eligibility_homebuyer_withdrawal, :eligibility_home_different_areas

    validates :eligibility_filing_status_mfj, presence: true
    validates :eligibility_homebuyer_withdrawal, presence: true
    validates :eligibility_home_different_areas, presence: true, if: -> {eligibility_filing_status_mfj}
    # TODO - validate :mfj_has in either case

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
