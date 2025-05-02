module StateFile
  module NjTenantEligibilityHelper
    INELIGIBLE = :ineligible
    WORKSHEET = :worksheet
    ADVANCE = :advance

    class << self
      def determine_eligibility(intake)
        is_ineligible = intake.tenant_home_subject_to_property_taxes_no? || (intake.tenant_building_multi_unit_yes? && intake.tenant_access_kitchen_bath_no?)

        if is_ineligible
          INELIGIBLE
        else
          ADVANCE
        end
      end
    end
  end
end