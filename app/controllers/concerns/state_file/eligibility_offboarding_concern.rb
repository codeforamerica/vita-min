module StateFile
  module EligibilityOffboardingConcern
    # This concern can be used by any controller that needs to redirect
    # to the eligibility offboarding page if given a disqualifying answer
    extend ActiveSupport::Concern

    private

    def offboarding_path
      StateFile::Questions::EligibilityOffboardingController.to_path_helper
    end

    def next_path
      if current_intake.has_disqualifying_eligibility_answer?
        session[:offboarded_from] = self.class.to_path_helper(from_path_params)
        return offboarding_path
      end

      super
    end

    def from_path_params
      [:us_state, :return_to_review].each_with_object({}) do |key, path_params|
        path_params[key] = params[key] if params[key].present?
      end
    end
  end
end