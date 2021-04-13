module Questions
  class TriagePrepareSoloController < AnonymousIntakeController
    layout "yes_no_question"

    skip_before_action :require_intake

    def illustration_path
      "person-check.svg"
    end

    def edit
      @form = form_class.new
    end

    def update
      @form = form_class.new(form_params)
      redirect_to next_path
    end

    def next_path
      @form.will_prepare? ? diy_file_yourself_path : super
    end

    def method_name
      "will_prepare"
    end
  end
end
