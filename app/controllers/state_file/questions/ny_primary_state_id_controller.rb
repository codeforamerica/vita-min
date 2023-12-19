module StateFile
  module Questions
    class NyPrimaryStateIdController < AuthenticatedQuestionsController
      include StateSpecificQuestionConcern

    end
  end
end
