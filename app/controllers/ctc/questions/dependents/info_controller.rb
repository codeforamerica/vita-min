module Ctc
  module Questions
    module Dependents
      class InfoController < BaseDependentController
        include AuthenticatedCtcClientConcern
        include RecaptchaScoreConcern

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

        def next_path
          if @dependent.born_after_tax_year?(TaxReturn.current_tax_year) || @dependent.filed_joint_return_yes?
            does_not_qualify_ctc_questions_dependent_path(id: @dependent.id)
          else
            super
          end
        end

        def form_params
          super.merge(recaptcha_score_param('dependents_info'))
        end

        def illustration_path
          "ssn-itins.svg"
        end
      end
    end
  end
end
