module Questions
  class EligibilityController < QuestionsController
    skip_before_action :require_sign_in
    layout "question"

    def current_intake
      @intake
    end

    def edit
      @intake = Intake.new
      super
    end

    def update
      @intake = Intake.find_by_id(session[:intake_id])
      return redirect_to feelings_questions_path unless @intake.present?

      if [:had_farm_income, :had_rental_income, :income_over_limit].any? { |attr| form_params[attr] == "yes" }
        @intake.update(form_params)
        @intake.update(source: source, referrer: referrer)
        redirect_to maybe_ineligible_path
      else
        super
      end
    end

    def illustration_path; end
  end
end