module Ctc
  module Questions
    module Dependents
      class InfoController < BaseDependentController
        include AuthenticatedCtcClientConcern

        layout "intake"

        def self.show?(dependent)
          return false if dependent.nil?

          dependent.intake.had_dependents_yes?
        end

        def current_resource
          @dependent ||= begin
            verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
            token = verifier.verified(params[:id])
            if token
              current_intake.dependents.find_or_initialize_by(creation_token: token)
            else
              super
            end
          end
        end

        private

        def illustration_path
          "ssn-itins.svg"
        end
      end
    end
  end
end
