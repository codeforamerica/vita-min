module Hub::StateFile
  class EfileErrorsController < Hub::StateFile::BaseController
    load_and_authorize_resource
    layout "hub"

    def index
      @efile_errors = @efile_errors.where.not(service_type: "ctc").order(:source, :code)
    end

    def edit
      intake = @efile_error.data_source
      navigation = "Navigation::StateFile#{intake.state_code.titleize}QuestionNavigation".constantize
      controllers = navigation.controllers
      start_index = controllers.index(StateFile::Questions::TermsAndConditionsController)
      end_index = controllers.index(StateFile::Questions::EsignDeclarationController)
      controllers = controllers[start_index..end_index]
      paths = controllers.map do |c|
        c.to_path_helper(action: c.navigation_actions.first, us_state: intake.state_code, locale: intake.locale || "en")
      end
      unless @efile_error.correction_path.present?
        @efile_error.correction_path = @efile_error.default_correction_path
      end
      @correction_path_options_for_select = paths
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
        submission_ids = EfileSubmissionTransitionError.includes(:efile_error, :efile_submission_transition).where(efile_error: @efile_error, efile_submission_transitions: { most_recent: true, to_state: ["rejected", "failed"] }).pluck(:efile_submission_id)
        EfileSubmission.where(id: submission_ids).find_each { |submission| submission.transition_to(auto_transition_to_state) }

        flash[:notice] = "Successfully reprocessed #{submission_ids.count} submission(s) with #{@efile_error.code} error!"
      else
        flash[:notice] = "Could not reprocess #{@efile_error.code}. Try again."
      end
      redirect_to hub_state_file_efile_error_path(id: @efile_error.id)
    end

    def permitted_params
      params.require(:efile_error).permit(:expose, :auto_cancel, :auto_wait, :correction_path, :description_en, :description_es, :resolution_en, :resolution_es)
    end
  end
end
