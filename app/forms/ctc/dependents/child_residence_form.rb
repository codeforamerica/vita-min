module Ctc
  module Dependents
    class ChildResidenceForm < DependentForm
      set_attributes_for :dependent, :months_in_home
      validates_presence_of :months_in_home

      def save
        lived_with_more_than_six_months = months_in_home.to_i >= 7 ? "yes" : "no"

        @dependent.update!(attributes_for(:dependent).merge(lived_with_more_than_six_months: lived_with_more_than_six_months))
      end
    end
  end
end
