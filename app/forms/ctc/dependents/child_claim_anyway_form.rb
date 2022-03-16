module Ctc
  module Dependents
    class ChildClaimAnywayForm < DependentForm
      set_attributes_for :dependent, :claim_anyway

      validates_presence_of :claim_anyway

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
