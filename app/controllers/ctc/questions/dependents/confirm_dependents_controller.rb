module Ctc
  module Questions
    module Dependents
      class ConfirmDependentsController < QuestionsController
        include AuthenticatedCtcClientConcern

        layout "intake"

        # def self.show?(intake)
        #   TODO: return false unless intake.dependents.count > 0
        # end

        private

        def form_class
          NullForm
        end

        def illustration_path; end
      end
    end
  end
end
