module Ctc
  module Questions
    module Dependents
      class InfoController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(intake, _dependent)
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

        def illustration_path; end
      end
    end
  end
end
