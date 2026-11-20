module Questions
  class DemographicEnglishReadingController < PostCompletionQuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.demographic_questions_opt_in_yes?
    end
  end
end
