module Questions
  class DemographicSpouseEthnicityController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      if intake == nil
        return false
      end
      intake.demographic_questions_opt_in_yes? && intake.filing_joint_yes?
    end

    def illustration_path; end

    private

    def next_path
      root_path
    end

    def after_update_success
      super
      if next_path == root_path
        clear_intake_session
      end
    end
  end
end