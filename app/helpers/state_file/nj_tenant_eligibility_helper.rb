module StateFile
  module NjTenantEligibilityHelper
    INELIGIBLE = :ineligible
    UNSUPPORTED = :unsupported
    ADVANCE = :advance

    class << self
      def determine_eligibility(intake)
        is_ineligible = intake.tenant_home_subject_to_property_taxes == 'no' || (intake.tenant_building_multi_unit == 'yes' && intake.tenant_access_kitchen_bath == 'no')
        is_unsupported = intake.tenant_more_than_one_main_home_in_nj == 'yes' || intake.tenant_shared_rent_not_spouse == 'yes'

        if is_ineligible
          INELIGIBLE
        elsif is_unsupported
          UNSUPPORTED
        else
          ADVANCE
        end
      end
    end
  end
end