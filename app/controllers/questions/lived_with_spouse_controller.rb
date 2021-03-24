module Questions
  class LivedWithSpouseController < AuthenticatedIntakeController
    layout "yes_no_question"

    def self.show?(intake)
      intake.ever_married_yes?
    end
  end
end
