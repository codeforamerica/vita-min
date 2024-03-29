module Hub
  class EfileSubmissionsController < Hub::BaseController
    include FilesConcern
    authorize_resource
    load_resource except: [:index, :show]
    layout "hub"

    def index
      @efile_submissions = EfileSubmission.includes(:efile_submission_transitions, tax_return: [:client, :intake]).most_recent_by_current_year_tax_return.page(params[:page])
      @efile_submissions = @efile_submissions.in_state(params[:status]) if params[:status].present?
    end

    # a little bit unexpectedly, the "show" page actually uses the client id to load the client. Then,
    # loops through the tax_returns that have efile_submissions.
    def show
      client = Client.find(params[:id])
      authorize! :read, client
      @client = Hub::ClientsController::HubClientPresenter.new(client)
      # Eager-load tax returns with submissions and data we may need to render
      @tax_returns = client.tax_returns.includes(:efile_submissions, efile_submissions: :fraud_score).where.not(tax_returns: {efile_submissions: nil}).load
      @fraud_indicators = Fraud::Indicator.unscoped
      redirect_to hub_client_path(id: @client.id) and return unless @tax_returns.joins(:efile_submissions).size.nonzero?
    end

    def resubmit
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:resubmitted, { initiated_by_id: current_user.id })
      flash[:notice] = "Resubmission initiated."
      redirect_after_action
    end

    def notify_of_rejection
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:notified_of_rejection, { initiated_by_id: current_user.id })
      flash[:notice] = "Filer Notified."
      redirect_after_action
    end

    def failed
      return if acts_like_production?

      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:failed, { initiated_by_id: current_user.id })
      flash[:notice] = "Transitioned to failed (for testing purpose only)"
      redirect_after_action
    end

    def cancel
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:cancelled, { initiated_by_id: current_user.id })
      flash[:notice] = "Submission cancelled, tax return marked 'Not filing'."
      redirect_after_action
    end

    def reject
      return if Rails.env.production?

      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:rejected, error_code: EfileError.where(service_type: :state_file).last.code)
      flash[:notice] = "Transitioned to rejected (for testing purpose only)"
      redirect_after_action
    end

    def investigate
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:investigating, { initiated_by_id: current_user.id })
      flash[:notice] = "Good luck on your investigation!"
      redirect_after_action
    end

    def wait
      authorize! :update, @efile_submission
      @efile_submission.transition_to!(:waiting, { initiated_by_id: current_user.id })
      flash[:notice] = "Waiting for client action."
      redirect_after_action
    end

    def redirect_after_action
      path = @efile_submission.is_for_state_filing? ? hub_state_file_efile_submission_path(id: @efile_submission.id) : hub_efile_submission_path(id: @efile_submission.client.id)
      redirect_back(fallback_location: path)
    end

    def state_counts
      @efile_submission_state_counts = EfileSubmission.state_counts(except: %w[new resubmitted ready_to_resubmit])
      respond_to :js
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
      redirect_to transient_storage_url(@efile_submission.submission_bundle.blob, disposition: "attachment"), allow_other_host: true
    end
  end
end
