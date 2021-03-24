module Questions
  class EligibilityController < AnonymousIntakeController
    layout "intake"

    private

    def next_path
      unless current_intake.eligible_for_vita?
        maybe_ineligible_path
      else
        super
      end
    end

    def illustration_path; end
  end
end
