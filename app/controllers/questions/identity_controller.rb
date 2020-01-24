module Questions
  class IdentityController < QuestionsController
    skip_before_action :ensure_intake_present
    layout "application"

    def self.form_class
      NullForm
    end

    def edit
      unless current_intake.present?
        set_new_intake
      end
    end

    def illustration_path
      controller_name.dasherize + ".svg"
    end
  end
end