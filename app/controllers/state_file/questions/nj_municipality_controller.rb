require 'csv'

module StateFile
  module Questions
    class NjMunicipalityController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
