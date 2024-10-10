module StateFile
  class MdEligibilityFilingStatusForm < QuestionsForm
    set_attributes_for :intake, :eligibility_filing_status

    validates :eligibility_filing_status, presence: true

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
