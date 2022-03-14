module Ctc
  module Dependents
    class ChildResidenceExceptionsForm < DependentForm
      set_attributes_for :dependent,
                         :residence_exception_born,
                         :residence_exception_passed_away,
                         :residence_exception_adoption,
                         :permanent_residence_with_client

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
