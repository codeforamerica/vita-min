module Hub
  class StateEfileSubmissionsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    layout "hub"

    def index
      @efile_submissions = EfileSubmission.where(data_source_type: ["StateFileAzIntake", "StateFileNyIntake"])
    end

  #   # a little bit unexpectedly, the "show" page actually uses the client id to load the client. Then,
  #   # loops through the tax_returns that have efile_submissions.
    def show
      @intake = StateFileAzIntake.find(params[:id])
    end

  #   def resubmit
  #     authorize! :update, @efile_submission
  #     @efile_submission.transition_to!(:resubmitted, { initiated_by_id: current_user.id })
  #     flash[:notice] = "Resubmission initiated."
  #     redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
  #   end
  #
  #   def cancel
  #     authorize! :update, @efile_submission
  #     @efile_submission.transition_to!(:cancelled, { initiated_by_id: current_user.id })
  #     flash[:notice] = "Submission cancelled, tax return marked 'Not filing'."
  #     redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
  #   end
  #
  #   def investigate
  #     authorize! :update, @efile_submission
  #     @efile_submission.transition_to!(:investigating, { initiated_by_id: current_user.id })
  #     flash[:notice] = "Good luck on your investigation!"
  #     redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
  #   end
  #
  #   def wait
  #     authorize! :update, @efile_submission
  #     @efile_submission.transition_to!(:waiting, { initiated_by_id: current_user.id })
  #     flash[:notice] = "Waiting for client action."
  #     redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
  #   end
  #
  #   def state_counts
  #     @efile_submission_state_counts = EfileSubmission.state_counts(except: %w[new resubmitted ready_to_resubmit])
  #     respond_to :js
  #   end
  #
  #   def download
  #     authorize! :read, @efile_submission
  #     if @efile_submission.submission_bundle.blank?
  #       head :not_found
  #       return
  #     end
  #
  #     AccessLog.create!(
  #       user: current_user,
  #       record: @efile_submission,
  #       event_type: "downloaded_submission_bundle",
  #       ip_address: request.remote_ip,
  #       user_agent: request.user_agent,
  #     )
  #     redirect_to transient_storage_url(@efile_submission.submission_bundle.blob, disposition: "attachment"), allow_other_host: true
  #   end
  end
end
