module Ctc
  module Questions
    module Dependents
      class ChildDisqualifiersController < BaseDependentController
        # include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(intake)
          intake.had_dependents_yes?
        end

        def edit
          super
        end

        def update
          super
        end

        private

        def illustration_path
        end
      end
    end
  end
end
