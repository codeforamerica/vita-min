module Questions
  class IdentityController < QuestionsController
    skip_before_action :require_sign_in
    layout "application"

    def self.form_class
      NullForm
    end

    def edit; end

    def illustration_path
      controller_name.dasherize + ".svg"
    end
  end
end