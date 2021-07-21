module Ctc
  module Questions
    module Dependents
      class TinController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(intake)
          intake.had_dependents_yes?
        end

        private

        def illustration_path
        end
      end
    end
  end
end
