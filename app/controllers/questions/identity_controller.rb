module Questions
  class IdentityController < QuestionsController
    skip_before_action :ensure_intake_present

    def self.form_class
      NullForm
    end

    def edit
      unless current_intake.present?
        set_new_intake
      end
    end

    def section_title
      "Personal Information"
    end
  end
end