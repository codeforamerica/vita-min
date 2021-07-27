module Ctc
  module Dependents
    class RemoveDependentForm < DependentForm
      def save
        @dependent.destroy!
      end
    end
  end
end
