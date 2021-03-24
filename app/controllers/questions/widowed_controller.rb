module Questions
  class WidowedController < AuthenticatedIntakeController
    layout "yes_no_question"

    def self.show?(intake)
      intake.ever_married_yes?
    end

    def illustration_path
      "marital-status.svg"
    end
  end
end
