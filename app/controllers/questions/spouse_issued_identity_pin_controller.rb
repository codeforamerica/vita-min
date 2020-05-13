module Questions
  class SpouseIssuedIdentityPinController < TicketedQuestionsController
    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def illustration_path
      "issued-identity-pin.svg"
    end
  end
end
