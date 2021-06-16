module Questions
  class DemographicDisabilityController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.demographic_questions_opt_in_yes?
    end

    def illustration_path; end
  end
end