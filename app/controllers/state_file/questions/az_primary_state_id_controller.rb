module StateFile
  module Questions
    class AzPrimaryStateIdController < AuthenticatedQuestionsController
      include StateSpecificQuestionConcern

    end
  end
end
