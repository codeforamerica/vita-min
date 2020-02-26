module Questions
  class EligibilityController < QuestionsController
    skip_before_action :require_sign_in
    before_action :require_intake

    layout "question"

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