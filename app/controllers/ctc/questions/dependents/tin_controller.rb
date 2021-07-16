module Ctc
  module Questions
    module Dependents
      class TinController < BaseDependentController
        # TODO: Transition to Authenticated once we log in client
        include AnonymousIntakeConcern

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
