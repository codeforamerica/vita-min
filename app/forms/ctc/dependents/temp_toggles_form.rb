module Ctc
  module Dependents
    class TempTogglesForm < DependentForm
      ATTRIBUTES = [
        :full_time_student,
        :permanently_totally_disabled,
        :provided_over_half_own_support,
        :no_ssn_atin,
        :filed_joint_return,
        :lived_with_more_than_six_months,
        :born_in_2020,
        :passed_away_2020,
        :placed_for_adoption,
        :permanent_residence_with_client,
        :cant_be_claimed_by_other,
        :claim_regardless,
        :meets_misc_qualifying_relative_requirements,
      ]
      set_attributes_for(:dependent, *ATTRIBUTES)

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
