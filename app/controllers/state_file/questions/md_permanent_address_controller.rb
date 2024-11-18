module StateFile
  module Questions
    class MdPermanentAddressController < QuestionsController
      include ReturnToReviewConcern
      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }
    end
  end
end
