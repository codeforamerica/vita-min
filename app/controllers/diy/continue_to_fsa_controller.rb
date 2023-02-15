module Diy
  class ContinueToFsaController < BaseController
    before_action :require_diy_intake

    def edit
      ExperimentService.find_or_assign_treatment(
        experiment_id: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT,
        record: DiyIntake.find(session[:diy_intake_id])
      )
      @taxslayer_link = "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=01011934"
    end

    private

    def require_diy_intake
      redirect_to diy_file_yourself_path unless session[:diy_intake_id].present?
    end
  end
end
