module Ctc
  module Dependents
    class RelativeFinancialSupportForm < DependentForm
      set_attributes_for :dependent, :filer_provided_over_half_support
      validates_presence_of :filer_provided_over_half_support

      def save
        @dependent.update(attributes_for(:dependent))
      end
    end
  end
end
