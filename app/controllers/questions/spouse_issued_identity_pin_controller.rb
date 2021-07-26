module Questions
  class SpouseIssuedIdentityPinController < QuestionsController
    include AuthenticatedClientConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.filing_joint == "yes"
    end

    def illustration_path
      "issued-identity-pin.svg"
    end
  end
end
