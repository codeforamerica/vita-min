module StateFile
  module Questions
    class NyPermanentAddressController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end
