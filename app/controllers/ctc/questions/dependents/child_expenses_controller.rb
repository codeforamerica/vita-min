module Ctc
  module Questions
    module Dependents
      class ChildExpensesController < BaseDependentController
        include AuthenticatedCtcClientConcern
        layout "yes_no_question"

        def method_name
          'provided_over_half_own_support'
        end

        def next_path
          if @dependent.provided_over_half_own_support_yes?
            does_not_qualify_ctc_questions_dependent_path(id: @dependent.id)
          else
            super
          end
        end

        private

        def illustration_path
          "dependents_home.svg"
        end
      end
    end
  end
end