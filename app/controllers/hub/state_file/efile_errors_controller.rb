module Hub::StateFile
  class EfileErrorsController < Hub::StateFile::BaseController
    load_and_authorize_resource
    layout "hub"

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
      @correction_path_options_for_select = EfileError.paths
      unless @efile_error.correction_path.present?
        @efile_error.correction_path = EfileError.controller_to_path(
          EfileError.default_controller(current_state_code)
        )
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
        auto_transition_to_state = @efile_error.auto_wait ? :waiting : :cancelled
        submission_ids = EfileSubmissionTransitionError.accessible_by(current_ability).includes(:efile_error, :efile_submission_transition).where(efile_error: @efile_error, efile_submission_transitions: { most_recent: true, to_state: ["rejected", "failed"] }).pluck(:efile_submission_id)
        EfileSubmission.accessible_by(current_ability).where(id: submission_ids).find_each { |submission| submission.transition_to(auto_transition_to_state) }

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

    def current_state_code
      @current_state_code ||= @efile_error.efile_submission.data_source.state_code
    end
  end
end
