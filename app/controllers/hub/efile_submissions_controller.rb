module Hub
  class EfileSubmissionsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    authorize_resource
    load_resource except: [:index, :show]
    layout "admin"

    def index
      @efile_submissions = EfileSubmission.most_recent_by_tax_return.page(params[:page])
      @efile_submissions = @efile_submissions.in_state(params[:status]) if params[:status].present?
    end

    # a little bit unexpectedly, the "show" page actually uses the client id to load the client. Then,
    # loops through the tax_returns that have efile_submissions.
    def show
      @client = Client.find(params[:id])
      @tax_returns = @client.tax_returns.joins(:efile_submissions).uniq # get all tax returns with submissions
      redirect_to hub_client_path(id: @client.id) and return unless @tax_returns.present?
    end

    def resubmit
      @efile_submission.transition_to!(:resubmitted, { initiated_by_id: current_user.id })
      flash[:notice] = "Resubmission initiated."
      redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
    end

    def cancel
      @efile_submission.transition_to!(:cancelled, { initiated_by_id: current_user.id })
      flash[:notice] = "Submission cancelled, tax return marked 'Not filing'."
      redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
    end

    def investigate
      @efile_submission.transition_to!(:investigating, { initiated_by_id: current_user.id })
      flash[:notice] = "Good luck on your investigation!"
      redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
    end
  end
end
