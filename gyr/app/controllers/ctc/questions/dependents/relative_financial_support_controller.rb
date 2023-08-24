module Ctc
  module Questions
    module Dependents
      class RelativeFinancialSupportController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def method_name
          'filer_provided_over_half_support'
        end

        private

        def illustration_path
          "dependents.svg"
        end
      end
    end
  end
end
