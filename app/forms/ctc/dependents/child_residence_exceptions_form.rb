module Ctc
  module Dependents
    class ChildResidenceExceptionsForm < DependentForm
      set_attributes_for :dependent,
                         :born_in_2020,
                         :passed_away_2020,
                         :placed_for_adoption,
                         :permanent_residence_with_client

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
