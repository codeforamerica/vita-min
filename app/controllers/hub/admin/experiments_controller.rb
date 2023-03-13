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

      def edit
        @experiment_form = ExperimentForm.new(@experiment)
      end

      def update
        vita_partners = params[:hub_admin_experiments_controller_experiment_form][:vita_partners]
        vita_partner_ids = vita_partners.blank? ? [] : JSON.parse(vita_partners).pluck("id")

        if @experiment.update(experiment_params.merge(vita_partner_ids: vita_partner_ids))
          flash[:notice] = I18n.t("general.changes_saved")
          redirect_to hub_admin_experiments_path
        else
          @experiment_form = ExperimentForm.new(@experiment)
          flash.now[:alert] = I18n.t("general.error.form_failed")
          render :edit
        end
      end

      private

      def experiment_params
        params.require(:hub_admin_experiments_controller_experiment_form).permit(:enabled)
      end

      class ExperimentForm < SimpleDelegator
        include ActiveModel::Model

        def initialize(experiment)
          __setobj__(experiment)
          @experiment = experiment
        end

        def vita_partners
          @experiment.vita_partners.map do |vp|
            { name: vp.name, value: vp.id }
          end.to_json
        end

        def vita_partners=(json)
          @experiment.vita_partner_ids = JSON.parse(json).pluck('id')
        end
      end
    end
  end
end
