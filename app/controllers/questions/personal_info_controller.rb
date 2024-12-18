module Questions
  class PersonalInfoController < QuestionsController
    include AnonymousIntakeConcern
    skip_before_action :require_intake

    def self.show?(intake, current_controller)
      intake.blank? || SourceParameter.source_skips_triage(current_controller.session[:source])
    end

    def current_intake
      super || Intake::GyrIntake.new
    end

    def tracking_data
      {}
    end

    def visitor_record
      Intake.find_by(id: session[:intake_id]) || current_intake
    end

    private

    def prev_path
      nil
    end

    def illustration_path; end

    ##
    # sets new intake id in session and associates triage source to that intake
    def after_update_success
      new_intake = @form.intake
      session[:intake_id] = new_intake.id
      new_intake.set_navigator(session[:navigator])

      if new_intake.client.routing_method.blank? || new_intake.client.routing_method_at_capacity?
        PartnerRoutingService.update_intake_partner(new_intake)
      end
    end

    def form_params
      super.merge(
        source: current_intake.source || source,
        referrer: current_intake.referrer || referrer,
        locale: I18n.locale,
        visitor_id: visitor_id
      )
    end
  end
end
