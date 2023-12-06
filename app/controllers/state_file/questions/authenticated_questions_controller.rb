module StateFile
  module Questions
    class AuthenticatedQuestionsController < StateFile::Questions::QuestionsController
      include AuthenticatedStateFileIntakeConcern
    end
  end
end
