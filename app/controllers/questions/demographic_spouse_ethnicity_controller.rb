module Questions
  class DemographicSpouseEthnicityController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.demographic_questions_opt_in_yes? && intake.filing_joint_yes?
    end

    def illustration_path; end
  end
end