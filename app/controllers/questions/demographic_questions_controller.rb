module Questions
  class DemographicQuestionsController < PostCompletionQuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def update
      super
      if next_path == root_path
        clear_intake_session
      end
    end

    private

    def next_path
      default_next_path = super
      if default_next_path.nil?
        root_path
      else
        default_next_path
      end
    end
  end
end
