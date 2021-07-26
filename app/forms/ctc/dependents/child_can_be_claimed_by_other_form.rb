module Ctc
  module Dependents
    class ChildCanBeClaimedByOtherForm < DependentForm
      set_attributes_for :dependent, :cant_be_claimed_by_other

      validates_presence_of :cant_be_claimed_by_other

      def save
        @dependent.assign_attributes(attributes_for(:dependent))
        @dependent.save
      end
    end
  end
end
