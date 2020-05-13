module Questions
  class SpouseWasBlindController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def illustration_path
      "was-blind.svg"
    end
  end
end