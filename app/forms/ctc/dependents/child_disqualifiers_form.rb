module Ctc
  module Dependents
    class ChildDisqualifiersForm < DependentForm
      set_attributes_for :dependent,
                         :filed_joint_return,
                         :provided_over_half_own_support
      set_attributes_for :confirmation, :none_of_the_above
      validates :none_of_the_above, at_least_one_or_none_of_the_above_selected: true

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end

      def at_least_one_selected
        filed_joint_return == "yes" || provided_over_half_own_support == "yes"
      end
    end
  end
end
