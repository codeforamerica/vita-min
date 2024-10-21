module StateFile
  class MdEligibilityFilingStatusForm < QuestionsForm
    set_attributes_for :intake, :eligibility_filing_status_mfj, :eligibility_homebuyer_withdrawal, :eligibility_homebuyer_withdrawal_mfj, :eligibility_home_different_areas

    validates :eligibility_filing_status_mfj, presence: true
    validates :eligibility_homebuyer_withdrawal_mfj, presence: true, if: -> { eligibility_filing_status_mfj == "yes" }
    validates :eligibility_homebuyer_withdrawal, presence: true, unless: -> { eligibility_filing_status_mfj == "yes" }
    validates :eligibility_home_different_areas, presence: true, if: -> { eligibility_filing_status_mfj == "yes" }

    validate :mfj_non_homebuyer_non_cross_county_filers

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def mfj_non_homebuyer_non_cross_county_filers
      return unless eligibility_filing_status_mfj == "yes"

      if eligibility_homebuyer_withdrawal_mfj == "yes" || eligibility_home_different_areas == "yes"
        @intake.errors.add(:eligibility_homebuyer_withdrawal_mfj) #  I18n.t("views.state_file.md_eligibility_filing_status_form.errors.mfj_non_homebuyer_non_cross_county_filers")
        return false
      end
    end
  end
end
