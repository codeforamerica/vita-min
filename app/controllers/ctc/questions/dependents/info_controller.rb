module Ctc
  module Questions
    module Dependents
      class InfoController < BaseDependentController
        include AuthenticatedCtcClientConcern

        before_action :redirect_if_deprecated_magic_new_id

        layout "intake"

        def self.show?(dependent)
          return false if dependent.nil?

          dependent.intake.had_dependents_yes?
        end

        private

        def illustration_path
          "ssn-itins.svg"
        end

        def redirect_if_deprecated_magic_new_id
          if params[:id].to_s == 'new'
            redirect_to Ctc::Questions::Dependents::HadDependentsController.to_path_helper
          end
        end
      end
    end
  end
end
