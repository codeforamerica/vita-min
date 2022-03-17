module Ctc
  module Questions
    module Dependents
      class ChildResidenceController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def method_name
          'lived_with_more_than_six_months'
        end

        private

        def illustration_path
          "dependents_home.svg"
        end
      end
    end
  end
end
