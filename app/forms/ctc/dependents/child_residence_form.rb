module Ctc
  module Dependents
    class ChildResidenceForm < DependentForm
      set_attributes_for :dependent, :months_in_home
      validates_presence_of :months_in_home

      def save
        @dependent.update!(attributes_for(:dependent))
      end
    end
  end
end
