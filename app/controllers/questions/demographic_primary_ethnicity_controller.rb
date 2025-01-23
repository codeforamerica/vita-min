module Questions
  class DemographicPrimaryEthnicityController < PostCompletionQuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def self.show?(intake) = false

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
