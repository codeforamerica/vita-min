module StateFile
  module NjHomeownerEligibilityHelper
    INELIGIBLE = :ineligible
    UNSUPPORTED = :unsupported
    ADVANCE = :advance

    class << self
      def determine_eligibility(intake)
        is_ineligible = intake.homeowner_home_subject_to_property_taxes_no? || (intake.homeowner_main_home_multi_unit_yes? && intake.homeowner_main_home_multi_unit_max_four_one_commercial_no?)
        is_unsupported = intake.homeowner_more_than_one_main_home_in_nj_yes? || intake.homeowner_shared_ownership_not_spouse_yes? || (intake.homeowner_main_home_multi_unit_yes? && intake.homeowner_main_home_multi_unit_max_four_one_commercial_yes?)

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