module Hub
  class EfileSubmissionsController < ApplicationController
    include AccessControllable
    include FilesConcern

    before_action :require_sign_in
    authorize_resource
    load_resource except: [:index, :show]
    layout "admin"

    def index
      @efile_submission_state_counts = count_efile_submission_states
      @efile_submissions = EfileSubmission.includes(:efile_submission_transitions, tax_return: [:client, :intake]).most_recent_by_tax_return.page(params[:page])
      @efile_submissions = @efile_submissions.in_state(params[:status]) if params[:status].present?
    end

    # a little bit unexpectedly, the "show" page actually uses the client id to load the client. Then,
    # loops through the tax_returns that have efile_submissions.
    def show
      @client = Client.find(params[:id])
      authorize! :read, @client
      @tax_returns = @client.tax_returns.joins(:efile_submissions).uniq # get all tax returns with submissions
      redirect_to hub_client_path(id: @client.id) and return unless @tax_returns.present?
    end

    def resubmit
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:resubmitted, { initiated_by_id: current_user.id })
      flash[:notice] = "Resubmission initiated."
      redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
    end

    def cancel
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:cancelled, { initiated_by_id: current_user.id })
      flash[:notice] = "Submission cancelled, tax return marked 'Not filing'."
      redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
    end

    def investigate
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:investigating, { initiated_by_id: current_user.id })
      flash[:notice] = "Good luck on your investigation!"
      redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
    end

    def wait
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:waiting, { initiated_by_id: current_user.id })
      flash[:notice] = "Waiting for client action."
      redirect_back(fallback_location: hub_efile_submission_path(id: @efile_submission.client.id))
    end

    def download
      authorize! :read, @efile_submission
      if @efile_submission.submission_bundle.blank?
        head :not_found
        return
      end

      AccessLog.create!(
        user: current_user,
        record: @efile_submission,
        event_type: "downloaded_submission_bundle",
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
      )
      redirect_to transient_storage_url(@efile_submission.submission_bundle.blob, disposition: "attachment")
    end

    private

    def count_efile_submission_states
      result = {}
      EfileSubmissionStateMachine.states.each { |state| result[state] = 0 }
      ActiveRecord::Base.connection.execute(<<~SQL).each { |row| result[row['to_state']] = row['count'] }
        SELECT to_state, COUNT(*) FROM "efile_submissions"
        LEFT OUTER JOIN efile_submission_transitions AS most_recent_efile_submission_transition ON (
          efile_submissions.id = most_recent_efile_submission_transition.efile_submission_id AND 
          most_recent_efile_submission_transition.most_recent = TRUE
        )
        WHERE most_recent_efile_submission_transition.to_state IS NOT NULL
        GROUP BY to_state
      SQL
      result.except("new", "resubmitted", "ready_to_resubmit")
    end
  end
end
