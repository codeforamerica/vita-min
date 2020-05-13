module Questions
  class SpouseHadDisabilityController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def illustration_path
      "had-disability.svg"
    end
  end
end
