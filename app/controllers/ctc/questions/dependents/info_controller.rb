module Ctc
  module Questions
    module Dependents
      class InfoController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(dependent)
          dependent.intake.had_dependents_yes?
        end

        def current_resource
          @dependent ||= begin
            if params[:id] == 'new'
              current_intake.dependents.new
            else
              super
            end
          end
        end

        private

        def illustration_path; end
      end
    end
  end
end
