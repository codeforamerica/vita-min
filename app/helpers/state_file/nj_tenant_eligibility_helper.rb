module StateFile
  module NjTenantEligibilityHelper
    INELIGIBLE = :ineligible
    WORKSHEET = :worksheet
    ADVANCE = :advance

    class << self
      def determine_eligibility(intake)
        is_ineligible = intake.tenant_home_subject_to_property_taxes_no? || (intake.tenant_building_multi_unit_yes? && intake.tenant_access_kitchen_bath_no?)
        requires_applicant_worksheet = intake.tenant_more_than_one_main_home_in_nj_yes? || intake.tenant_shared_rent_not_spouse_yes?

        if is_ineligible
          INELIGIBLE
        elsif requires_applicant_worksheet
          WORKSHEET
        else
          ADVANCE
        end
      end
    end
  end
end