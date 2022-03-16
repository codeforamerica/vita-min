module Ctc
  module Dependents
    class RelativeMemberOfHouseholdForm < DependentForm
      set_attributes_for :dependent, :residence_lived_with_all_year
      validates_presence_of :residence_lived_with_all_year

      def save
        @dependent.update(attributes_for(:dependent))
      end
    end
  end
end
