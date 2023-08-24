module Ctc
  module Questions
    module W2s
      class EmployeeInfoController < BaseW2Controller
        def current_resource
          @_resource ||= begin
                           verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
                           token = verifier.verified(params[:id])
                           if token
                             current_intake.w2s_including_incomplete.find_or_initialize_by(creation_token: token)
                           else
                             super
                           end
                         end
        end
      end
    end
  end
end
