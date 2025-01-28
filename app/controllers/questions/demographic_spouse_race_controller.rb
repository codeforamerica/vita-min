module Questions
  class DemographicSpouseRaceController < PostCompletionQuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake&.demographic_questions_opt_in_yes? && intake&.filing_joint_yes?
    end

    def illustration_path; end

    private

    def next_path
      root_path
    end

    def after_update_success
      super

      GenerateF13614cPdfJob.perform_later(current_intake.id)

      if next_path == root_path
        clear_intake_session
      end
    end
  end
end
