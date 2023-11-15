module StateFile
  module ReturnToReviewConcern
    # This concern can be used by any controller that sometimes needs to redirect
    # to the review page rather than the usual next page in the flow
    extend ActiveSupport::Concern

    private

    def review_step
      case params[:us_state]
      when 'az'
        StateFile::Questions::AzReviewController
      when 'ny'
        StateFile::Questions::NyReviewController
      end
    end

    def next_step
      params[:return_to_review].nil? ? super : review_step
    end
  end
end