module Hub
  class EfileSubmissionsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    authorize_resource
    load_resource only: [:resubmit]
    layout "admin"

    def index
      @efile_submissions = EfileSubmission.most_recent_by_tax_return.page(params[:page])
    end

    def show
      @tax_return = TaxReturn.joins(:efile_submissions).find(params[:id])
      @efile_submission = @tax_return.efile_submissions.last
    end

    def resubmit
      @efile_submission.transition_to!(:resubmitted, { initiated_by_id: current_user.id })
      flash[:notice] = "Resubmission initiated."
      redirect_to hub_efile_submission_path(id: @efile_submission.tax_return)
    end
  end
end