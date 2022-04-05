module Questions
  class SuccessfullySubmittedController < PostCompletionQuestionsController
    include AuthenticatedClientConcern

    def include_analytics?
      true
    end

    private

    def self.form_key
      "satisfaction_face_form"
    end
  end
end
