module Questions
  class BacktaxesController < QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake
    before_action :load_possible_filing_years, only: [:edit, :update]
    layout "intake"

    def current_intake
      Intake::GyrIntake.new
    end

    def edit
      # skip this question if they answered that they only haven't filed for the current year
      # and save on the intake that they need help for the current year
      if current_triage.present? && only_current_tax_year_not_filed(current_triage)
        @form = BacktaxesForm.new(current_intake, form_params)
        @form.save
        @form.intake.update(needs_help_2021: "yes")

        after_update_success
        redirect_to(next_path)
      else
        super
      end
    end

    private

    ##
    # sets new intake id in session and associates triage source to that intake
    def after_update_success
      new_intake = @form.intake
      session[:intake_id] = new_intake.id
      new_intake.set_navigator(session[:navigator])
      current_triage&.update(intake_id: new_intake.id)
    end

    def form_params
      super.merge(
        source: current_intake.source || source,
        referrer: current_intake.referrer || referrer,
        locale: I18n.locale,
        visitor_id: visitor_id
      )
    end

    def illustration_path
      "calendar.svg"
    end

    def load_possible_filing_years
      @possible_filing_years =
        if current_triage.present?
          TaxReturn.filing_years.reject { |year| current_triage.send("filed_#{year}") == "yes" }
        else
          TaxReturn.filing_years
        end.sort
    end

    def only_current_tax_year_not_filed(triage)
      triage.send("filed_#{current_tax_year}") == "no" &&
        Array((current_tax_year - 3)...current_tax_year).all? { |year| triage.send("filed_#{year}") == "yes" }
    end
  end
end
