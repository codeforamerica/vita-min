require 'csv'

module StateFile
  module Questions
    class NySchoolDistrictController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
    end
  end
end
