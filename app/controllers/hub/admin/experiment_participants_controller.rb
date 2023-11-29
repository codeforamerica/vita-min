module Hub
  module Admin
    class ExperimentParticipantsController < Hub::BaseController
      load_and_authorize_resource
      layout "hub"
      before_action :redirect_on_prod, only: [:update]

      def edit; end

      def update
        if @experiment_participant.update(experiment_participant_params)
          flash[:notice] = I18n.t("general.changes_saved")
          redirect_to hub_admin_experiments_path
        else
          flash.now[:alert] = I18n.t("general.error.form_failed")
          render :edit
        end
      end

      private

      def redirect_on_prod
        redirect_to :edit if Rails.env.production?
      end

      def experiment_participant_params
        params.require(:experiment_participant).permit(:treatment)
      end
    end
  end
end
