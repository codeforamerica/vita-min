module Ctc
  module Dependents
    class ChildLivedWithYouForm < DependentForm
      set_attributes_for :dependent, :lived_with_less_than_six_months

      validates_presence_of :lived_with_less_than_six_months

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
