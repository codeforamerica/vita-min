module Ctc
  module Dependents
    class ChildResidenceForm < DependentForm
      set_attributes_for :dependent, :months_in_home
      validates_presence_of :months_in_home

      def save
        attrs = attributes_for(:dependent)
        unless @dependent.intake.claim_eitc_yes?
          attrs[:months_in_home] = attrs[:months_in_home] >= 7 ? 7 : 6
        end
        @dependent.update!(attrs)
      end
    end
  end
end
