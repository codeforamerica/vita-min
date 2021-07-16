module Ctc
  module Questions
    module Dependents
      class InfoController < BaseDependentController
        # TODO: Transition to Authenticated once we log in client
        include AnonymousIntakeConcern

        layout "intake"

        def self.show?(intake)
          intake.had_dependents_yes?
        end

        private

        def current_dependent
          @dependent ||= begin
            if params[:id] == 'new'
              current_intake.dependents.new
            else
              super
            end
          end
        end

        def illustration_path
        end
      end
    end
  end
end
