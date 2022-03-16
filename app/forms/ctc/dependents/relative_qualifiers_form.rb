module Ctc
  module Dependents
    class RelativeQualifiersForm < DependentForm
      set_attributes_for :dependent,
                         :cant_be_claimed_by_other,
                         :below_qualifying_relative_income_requirement
      set_attributes_for :confirmation, :none_of_the_above
      validates :none_of_the_above, at_least_one_or_none_of_the_above_selected: true

      def save
        @dependent.update(attributes_for(:dependent))
      end

      def at_least_one_selected
        cant_be_claimed_by_other == "yes" || below_qualifying_relative_income_requirement == "yes"
      end
    end
  end
end
