module Questions
  class SpouseOnVisaController < QuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def illustration_path
      "on-visa.svg"
    end
  end
end