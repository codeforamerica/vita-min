module StateFile
  class MdHealthcareScreenForm < QuestionsForm
    set_attributes_for :intake, :had_hh_member_without_health_insurance, :primary_did_not_have_health_insurance, :spouse_did_not_have_health_insurance, :authorize_sharing_of_health_insurance_info
    set_attributes_for :state_file_dependents, :dependents_did_not_have_health_insurance

    validates :had_hh_member_without_health_insurance, presence: true

    attr_accessor :dependents_did_not_have_health_insurance

    # validates :eligibility_filing_status_mfj, presence: true
    # validates :eligibility_homebuyer_withdrawal_mfj, presence: true, if: -> { eligibility_filing_status_mfj == "yes" }
    # validates :eligibility_homebuyer_withdrawal, presence: true, unless: -> { eligibility_filing_status_mfj == "yes" }
    # validates :eligibility_home_different_areas, presence: true, if: -> { eligibility_filing_status_mfj == "yes" }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
