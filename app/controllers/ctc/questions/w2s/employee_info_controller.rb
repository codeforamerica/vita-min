module Ctc
  module Questions
    module W2s
      class EmployeeInfoController < BaseW2Controller

        # def self.show?(intake)
        #   Flipper.enabled?(:eitc) &&
        #     intake.exceeded_investment_income_limit_no? &&
        #     intake.primary_birth_date > 24.years.ago &&
        #     intake.dependents.none?(&:qualifying_eitc?)
        # end

        def current_resource
          OpenStruct.new(cool: 'beans', id: 12345)
          # @w2 ||= current_intake.w2s.new
          # @dependent ||= begin
          #                  verifier = ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
          #                  token = verifier.verified(params[:id])
          #                  if token
          #                    current_intake.dependents.find_or_initialize_by(creation_token: token)
          #                  else
          #                    super
          #                  end
          #                end
        end

        private

        def illustration_path; end
      end
    end
  end
end
