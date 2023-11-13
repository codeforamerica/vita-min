module StateFile
  module EligibilityOffboardingConcern
    # This concern can be used by any controller that needs to redirect
    # to the eligibility offboarding page if given a disqualifying answer
    extend ActiveSupport::Concern

    private

    def offboarding_path
      StateFile::Questions::EligibilityOffboardingController.to_path_helper(us_state: params[:us_state])
    end

    def next_path
      if current_intake.has_disqualifying_eligibility_answer?
        session[:offboarded_from] = self.class.to_path_helper(us_state: params[:us_state])
        return offboarding_path
      end

      super
    end
  end
end