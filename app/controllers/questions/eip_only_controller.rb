module Questions
  class EipOnlyController < AnonymousIntakeController
    # this is a placeholder until we finish the streamlined eip intake
    layout "intake"

    def self.show?(_intake)
      false
    end

    def current_intake
      super || Intake.new
    end

    def illustration_path
      nil
    end

    def after_update_success
      session[:intake_id] = @form.intake.id
    end
  end
end
