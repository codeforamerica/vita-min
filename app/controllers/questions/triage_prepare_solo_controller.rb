module Questions
  class TriagePrepareSoloController < TriageController
    layout "yes_no_question"

    private

    def illustration_path
      "person-check.svg"
    end

    def next_path
      @form.will_prepare? ? diy_file_yourself_path : super
    end

    def method_name
      "will_prepare"
    end
  end
end
