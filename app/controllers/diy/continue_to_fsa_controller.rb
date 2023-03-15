module Diy
  class ContinueToFsaController < BaseController
    before_action :require_diy_intake

    def edit
      intake = DiyIntake.find(session[:diy_intake_id])
      treatment = if intake.received_1099_yes?
        ExperimentService.find_or_assign_treatment(
          key: ExperimentService::DIY_1099_SUPPORT_LEVEL_EXPERIMENT,
          record: intake
        )
      else
        ExperimentService.find_or_assign_treatment(
          key: ExperimentService::DIY_W2_SUPPORT_LEVEL_EXPERIMENT,
          record: intake
        )
      end
      @taxslayer_link = DiySupportExperimentService.taxslayer_link(treatment)
    end

    private

    def require_diy_intake
      redirect_to diy_file_yourself_path unless session[:diy_intake_id].present?
    end
  end
end
