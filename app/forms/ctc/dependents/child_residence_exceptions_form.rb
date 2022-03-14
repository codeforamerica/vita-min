module Ctc
  module Dependents
    class ChildResidenceExceptionsForm < DependentForm
      set_attributes_for :dependent, :permanent_residence_with_client

      def save
        @dependent.update(attributes_for(:dependent))
      end
    end
  end
end
