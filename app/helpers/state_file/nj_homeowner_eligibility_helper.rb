module StateFile
  module NjHomeownerEligibilityHelper
    class << self

      def determine_eligibility(intake)
        is_ineligible = intake.homeowner_home_subject_to_property_taxes == 'no' || (intake.homeowner_main_home_multi_unit == 'yes' && intake.homeowner_main_home_multi_unit_max_four_one_commercial == 'no')
        is_unsupported = intake.homeowner_more_than_one_main_home_in_nj == 'yes' || intake.homeowner_shared_ownership_not_spouse == 'yes' || (intake.homeowner_main_home_multi_unit == 'yes' && intake.homeowner_main_home_multi_unit_max_four_one_commercial == 'yes')

        if is_ineligible
          'ineligible'
        elsif is_unsupported
          'unsupported'
        else
          'advance'
        end
      end
    end
  end
end