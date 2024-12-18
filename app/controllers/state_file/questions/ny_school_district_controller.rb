require 'csv'

module StateFile
  module Questions
    class NySchoolDistrictController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
