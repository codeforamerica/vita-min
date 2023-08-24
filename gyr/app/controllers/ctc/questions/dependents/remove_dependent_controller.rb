module Ctc
  module Questions
    module Dependents
      class RemoveDependentController < BaseDependentController
        include AuthenticatedCtcClientConcern
        include PreviousPathIsBackConcern

        layout "intake"

        def self.show?(dependent)
          dependent.present?
        end

        def self.model_for_show_check(current_controller)
          current_controller.visitor_record
        end

        private

        def next_path
          questions_confirm_dependents_path
        end

        def illustration_path; end
      end
    end
  end
end
