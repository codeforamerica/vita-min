module Hub
  module Admin
    class ExperimentsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      before_action :load_vita_partners, only: [:edit]
      load_and_authorize_resource
      layout "hub"

      def index
        @experiments = Experiment.all
        @experiment_participants = ExperimentParticipant.page(params[:page]).load
      end

      def edit; end

      def update
        vita_partner_ids = JSON.parse(params[:experiment][:vita_partners]).pluck("id")
        if @experiment.update(experiment_params.merge(vita_partner_ids: vita_partner_ids))
          flash[:notice] = I18n.t("general.changes_saved")
          redirect_to hub_admin_experiments_path
        else
          flash.now[:alert] = I18n.t("general.error.form_failed")
          render :edit
        end
      end

      private

      def experiment_params
        params.require(:experiment).permit(:enabled)
      end
    end
  end
end
