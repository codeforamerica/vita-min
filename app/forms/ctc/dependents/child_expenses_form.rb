module Ctc
  module Dependents
    class ChildExpensesForm < DependentForm
      set_attributes_for :dependent,
                         :provided_over_half_own_support

      def save
        @dependent.update!(attributes_for(:dependent))
      end
    end
  end
end