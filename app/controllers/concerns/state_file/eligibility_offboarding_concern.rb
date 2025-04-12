module StateFile
  module EligibilityOffboardingConcern
    # This concern can be used by any controller that needs to redirect
    # to the eligibility offboarding page if given a disqualifying answer
    extend ActiveSupport::Concern

    included do
      before_action :clear_offboarded_from, only: :edit
    end

    private

    def clear_offboarded_from
      if session[:offboarded_from].present?
        session.delete(:offboarded_from)
      end
    end

    def offboarding_path
      StateFile::Questions::EligibilityOffboardingController.to_path_helper
    end

    def next_path
      if current_intake.has_disqualifying_eligibility_answer?
        session[:offboarded_from] = self.class.to_path_helper(params.permit(:return_to_review, :return_to_review_before, :return_to_review_after, :item_index))
        return offboarding_path
      end

      super
    end
  end
end
