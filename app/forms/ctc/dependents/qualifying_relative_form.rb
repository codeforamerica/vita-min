module Ctc
  module Dependents
    class QualifyingRelativeForm < DependentForm
      set_attributes_for :dependent, :meets_misc_qualifying_relative_requirements

      validates_presence_of :meets_misc_qualifying_relative_requirements

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
