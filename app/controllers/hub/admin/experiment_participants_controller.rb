module Hub
  module Admin
    class ExperimentParticipantsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource
      layout "hub"

      def edit; end

      def update
        if @experiment_participant.update(experiment_participant_params)
          @experiment_participant.save
          flash[:notice] = I18n.t("general.changes_saved")
          redirect_to hub_admin_experiments_path
        else
          flash.now[:alert] = I18n.t("general.error.form_failed")
          render :edit
        end
      end

      private

      def experiment_participant_params
        params.require(:experiment_participant).permit(:treatment)
      end
    end
  end
end
