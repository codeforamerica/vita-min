module Diy
  class ContinueToFsaController < BaseController
    before_action :require_diy_intake

    def edit
      diy_intake = DiyIntake.find(session[:diy_intake_id])
      ExperimentService.find_or_assign_treatment(
        key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT,
        record: diy_intake
      )
    end

    def click_fsa_link
      # We switched to a hardcoded link for now
      diy_intake = DiyIntake.find(session[:diy_intake_id])
      treatment = ExperimentParticipant.find_by(
        experiment: Experiment.find_by(key: ExperimentService::DIY_SUPPORT_LEVEL_EXPERIMENT),
        record: diy_intake
      )&.treatment
      if treatment == 'high'
        mailer_class_and_method = {
          mail_class: 'DiyIntakeEmailMailer',
          mail_method: 'high_support_message',
        }
        mail_args = ActiveJob::Arguments.serialize(diy_intake: diy_intake)

        if InternalEmail.where(mailer_class_and_method).where("mail_args::jsonb = ?::jsonb", JSON.dump(mail_args)).none?
          internal_email = InternalEmail.create!(mailer_class_and_method.merge(mail_args: mail_args))
          SendInternalEmailJob.perform_later(internal_email)
        end
      end
      redirect_to DiySupportExperimentService.fsa_link(treatment.to_s, diy_intake.received_1099_yes?), allow_other_host: true
    end

    private

    def require_diy_intake
      redirect_to diy_file_yourself_path unless session[:diy_intake_id].present?
    end
  end
end
