module Questions
  class SpouseIssuedIdentityPinController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def section_title
      "Personal Information"
    end

    def illustration_path; end
  end
end