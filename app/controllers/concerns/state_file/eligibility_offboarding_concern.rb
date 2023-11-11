module StateFile
  module EligibilityOffboardingConcern
    # This concern can be used by any controller that needs to redirect
    # to the eligibility offboarding page if given a disqualifying answer
    extend ActiveSupport::Concern

    private

    def offboarding_path
      StateFile::Questions::EligibilityOffboardingController.to_path_helper(action: :edit, us_state: params[:us_state])
    end

    def next_path
      return offboarding_path if current_intake.has_disqualifying_eligibility_answer?

      super
    end
  end
end