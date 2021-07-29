module Hub
  class EfileSubmissionsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    authorize_resource
    load_resource except: [:index, :show]
    layout "admin"

    def index
      @efile_submissions = EfileSubmission.most_recent_by_tax_return.page(params[:page])
    end

    # a little bit unexpectedly, the "show" page actually loads the tax return will all associated submissions
    # instead of a single submission.
    # However, efile_submission instance variable for most recent submission is used for access control and
    # to display information about overall status on the show page.
    def show
      @tax_return = TaxReturn.joins(:efile_submissions).find(params[:id])
      @efile_submission = @tax_return.efile_submissions.last
    end

    def resubmit
      @efile_submission.transition_to!(:resubmitted, { initiated_by_id: current_user.id })
      flash[:notice] = "Resubmission initiated."
      redirect_to hub_efile_submission_path(id: @efile_submission.tax_return)
    end

    def cancel
      @efile_submission.transition_to!(:cancelled, { initiated_by_id: current_user.id })
      flash[:notice] = "Submission cancelled, tax return marked 'Not filing'."
      redirect_to hub_efile_submission_path(id: @efile_submission.tax_return)
    end
  end
end