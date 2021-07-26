module Ctc
  module Dependents
    class ClaimChildAnywayForm < DependentForm
      set_attributes_for :dependent, :claim_regardless

      validates_presence_of :claim_regardless

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
