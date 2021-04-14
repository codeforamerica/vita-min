module Questions
  class TriageSimpleTaxController < TriageController
    layout "yes_no_question"

    def illustration_path
      "documents.svg"
    end

    def next_path
      @form.has_simple_taxes? ? diy_file_yourself_path : super
    end

    def method_name
      "has_simple_taxes"
    end
  end
end
