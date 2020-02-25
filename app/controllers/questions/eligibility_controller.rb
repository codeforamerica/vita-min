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
      if [:had_farm_income, :had_rental_income, :income_over_limit].any? { |attr| form_params[attr] == "yes" }
        @intake = Intake.create(form_params)
        @intake.update(source: source, referrer: referrer)
        session[:intake_id] = @intake.id
        redirect_to maybe_ineligible_path
      else
        @intake = Intake.create(source: source, referrer: referrer)
        session[:intake_id] = @intake.id
        super
      end
    end

    def illustration_path; end
  end
end