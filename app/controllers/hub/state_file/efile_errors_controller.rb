module Hub::StateFile
  class EfileErrorsController < Hub::StateFile::BaseController
    layout "hub"

    if Flipper.enabled?(:use_pundit)
      after_action :verify_authorized
      after_action :verify_policy_scoped, only: :index
      before_action :set_and_authorize_efile_error, only: [:edit, :show, :update, :reprocess]
      before_action :set_and_authorize_efile_errors, only: :index
    else
      load_and_authorize_resource
    end

    def index
      order = [:source, :code]
      if params[:sort_by].present?
        order.prepend(params[:sort_by])
      end

      @efile_errors = @efile_errors.where.not(service_type: "ctc").order(*order)

      if params[:filter_by_service_type].present?
        @efile_errors = @efile_errors.where(service_type: params[:filter_by_service_type])
      end
    end

    def edit
      state_code = @efile_error.service_type.sub("state_file_", "")
      @correction_path_options_for_select = EfileError.paths
      if StateFile::StateInformationService.active_state_codes.include?(state_code)
        unless @efile_error.correction_path.present?

          @efile_error.correction_path = EfileError.controller_to_path(
            EfileError.default_controller(state_code)
          )
        end
      end
    end

    def show; end

    def update
      if @efile_error.update(permitted_params)
        flash[:notice] = "#{@efile_error.code} updated!"
      else
        flash[:error] = "Could not update #{@efile_error.code}. Try again."
      end
      redirect_to hub_state_file_efile_error_path(id: @efile_error.id)
    end

    def reprocess
      if @efile_error.present? && (@efile_error.auto_wait || @efile_error.auto_cancel)
        submission_ids = EfileSubmissionTransitionError.accessible_by(current_ability)
                                                       .includes(:efile_error, :efile_submission_transition)
                                                       .where(
                                                         efile_error: @efile_error,
                                                         efile_submission_transitions: { most_recent: true, to_state: ["rejected", "failed"] }
                                                       )
                                                       .pluck(:efile_submission_id)
        EfileSubmission.accessible_by(current_ability).where(id: submission_ids).find_each do |submission|
          submission.transition_to(auto_transition_to_state(@efile_error, submission))
        end

        flash[:notice] = "Successfully reprocessed #{submission_ids.count} submission(s) with #{@efile_error.code} error!"
      else
        flash[:notice] = "Could not reprocess #{@efile_error.code}. Try again."
      end
      redirect_to hub_state_file_efile_error_path(id: @efile_error.id)
    end

    def permitted_params
      params.require(:efile_error).permit(:expose, :auto_cancel, :auto_wait, :correction_path, :description_en, :description_es, :resolution_en, :resolution_es)
    end

    private

    # what what happens on create/new when it doesn't exist in scope
    def set_and_authorize_efile_error
      @efile_error ||= EfileError.find(params[:id])
      authorize @efile_error
      unless policy_scope(EfileError).where(id: @efile_error.id).exists?
        raise Pundit::NotAuthorizedError
      end
    end

    def set_and_authorize_efile_errors
      authorize EfileError
      @efile_errors ||= policy_scope(EfileError)
    end

    def auto_transition_to_state(efile_error, submission)
      return :cancelled if efile_error.auto_cancel

      transition = submission.last_transition
      all_errors_auto_wait = transition.efile_errors.all?(&:auto_wait)
      if submission.current_state == "rejected"
        all_errors_auto_wait ? :notified_of_rejection : :waiting
      elsif all_errors_auto_wait # failed current_state
        :waiting
      end
    end
  end
end
