module Questions
  class DemographicPrimaryEthnicityController < QuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake)
      intake.demographic_questions_opt_in_yes?
    end

    def illustration_path; end

    def next_path
      default_next_path = super
      if default_next_path.nil?
        root_path
      else
        default_next_path
      end
    end

    private

    def after_update_success
      super
      if next_path == root_path
        clear_intake_session
      end
    end
  end
end