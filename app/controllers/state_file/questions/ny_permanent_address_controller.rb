module StateFile
  module Questions
    class NyPermanentAddressController < AuthenticatedQuestionsController
      include EligibilityOffboardingConcern
      include StateSpecificQuestionConcern

    end
  end
end
