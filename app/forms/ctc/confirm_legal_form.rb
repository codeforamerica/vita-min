module Ctc
  class ConfirmLegalForm < QuestionsForm
    set_attributes_for :intake, :consented_to_legal
    set_attributes_for :efile_security_information,
                       :device_id,
                       :user_agent,
                       :browser_language,
                       :platform,
                       :timezone_offset,
                       :client_system_time,
                       :ip_address,
                       :recaptcha_score

    validates :consented_to_legal, acceptance: { accept: 'yes', message: I18n.t("views.ctc.questions.confirm_legal.error") }
    validates_presence_of :device_id, :user_agent, :browser_language, :platform, :timezone_offset, :client_system_time, :ip_address

    def save
      intake_attributes = attributes_for(:intake)
      intake_attributes[:completed_at] = DateTime.current unless @intake.completed_at.present?
      @intake.update(intake_attributes)
      efile_attrs = attributes_for(:efile_security_information)

      unless @intake.tax_returns.last.efile_submissions.any?
        EfileSecurityInformation.create(efile_attrs.merge(client: @intake.client))
        efile_submission = EfileSubmission.create(tax_return: @intake.tax_returns.last)
        begin
          efile_submission.transition_to(:preparing)
        rescue Statesman::GuardFailedError
          Rails.logger.error "Failed to transition EfileSubmission##{efile_submission.id} to :preparing"
        end
      end
    end
  end
end
