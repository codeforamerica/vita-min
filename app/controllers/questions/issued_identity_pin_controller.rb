module Questions
  class IssuedIdentityPinController < QuestionsController
    layout "yes_no_question"

    def section_title
      "Personal Information"
    end

    def illustration_path; end
  end
end