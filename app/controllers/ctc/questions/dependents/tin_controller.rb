module Ctc
  module Questions
    module Dependents
      class TinController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(intake)
          intake.had_dependents_yes?
        end

        def self.model_for_show_check(current_controller)
          current_controller.visitor_record
        end

        private

        def illustration_path
        end
      end
    end
  end
end
