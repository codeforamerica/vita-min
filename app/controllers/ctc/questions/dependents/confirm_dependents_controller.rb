module Ctc
  module Questions
    module Dependents
      class ConfirmDependentsController < QuestionsController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(intake)
          intake.had_dependents_yes?
        end

        def update
          if params[:add_a_dependent]
            redirect_to Ctc::Questions::Dependents::InfoController.to_path_helper(
              id: current_intake.find_blank_dependent_or_create_dependent.id
            )
          else
            super
          end
        end

        private

        def form_class
          NullForm
        end

        def illustration_path; end
      end
    end
  end
end
