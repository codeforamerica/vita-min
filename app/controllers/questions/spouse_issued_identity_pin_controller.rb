module Questions
  class SpouseIssuedIdentityPinController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint_yes?
    end
  end
end
