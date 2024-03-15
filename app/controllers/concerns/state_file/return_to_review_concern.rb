module StateFile
  module ReturnToReviewConcern
    # This concern can be used by any controller that sometimes needs to redirect
    # to the review page rather than the usual next page in the flow
    extend ActiveSupport::Concern

    def review_step
      "StateFile::Questions::#{current_intake.state_code.titleize}ReviewController".constantize
    end

    private

    def next_step
      params[:return_to_review].nil? ? super : review_step
    end

    def prev_step
      params[:return_to_review].nil? ? super : review_step
    end
  end
end