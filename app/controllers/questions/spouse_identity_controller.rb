module Questions
  class SpouseIdentityController < QuestionsController
    layout "question"

    def section_title
      "Personal Information"
    end

    def self.form_class
      NullForm
    end

    def self.show?(intake)
      intake.filing_joint_yes?
    end
  end
end