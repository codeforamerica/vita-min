module Diy
  class ContinueToFsaController < BaseController
    before_action :require_diy_intake

    def edit
      intake = DiyIntake.find(session[:diy_intake_id])
      treatment = ExperimentService.find_or_assign_treatment(
        key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT,
        record: intake
      )
      @taxslayer_link = DiySupportExperimentService.taxslayer_link(treatment, intake.received_1099_yes?)
    end

    def click_fsa_link
      intake = DiyIntake.find(session[:diy_intake_id])
      treatment = ExperimentParticipant.find_by(
        experiment: Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT),
        record: intake
      )&.treatment
      if treatment == 'high'
        internal_email = InternalEmail.create!(
          mail_class: DiyIntakeEmailMailer,
          mail_method: :high_support_message,
          mail_args: ActiveJob::Arguments.serialize(
            diy_intake: intake
          )
        )
        SendInternalEmailJob.perform_later(internal_email)
      end
      redirect_to DiySupportExperimentService.taxslayer_link(treatment, intake.received_1099_yes?), allow_other_host: true
    end

    private

    def require_diy_intake
      redirect_to diy_file_yourself_path unless session[:diy_intake_id].present?
    end
  end
end
