module StateFile
  module Questions
    class MdPermanentAddressController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end
