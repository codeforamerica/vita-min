module StateFile
  module Questions
    # TODO: rename this to AzMadePublicSchoolContributionsController?
    class AzMadeAz322ContributionsController < QuestionsController
      include ReturnToReviewConcern
    #  TODO: destroy existing records if they go back and asnwer no??
    end
  end
end
