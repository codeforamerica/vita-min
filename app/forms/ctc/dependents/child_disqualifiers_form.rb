module Ctc
  module Dependents
    class ChildDisqualifiersForm < DependentForm
      set_attributes_for :dependent,
                         :filed_joint_return,
                         :no_ssn_atin,
                         :provided_over_half_own_support
      set_attributes_for :none_of_the_above
      # not sure if should also fill was_married
      # meets_misc_qualifying_relative_requirements

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
