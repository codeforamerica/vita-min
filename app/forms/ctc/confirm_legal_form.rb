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
                       :ip_address

    validates :consented_to_legal, acceptance: { accept: 'yes', message: I18n.t("views.ctc.questions.confirm_legal.error") }
    validates_presence_of :device_id, :user_agent, :browser_language, :platform, :timezone_offset, :client_system_time, :ip_address

    def save
      @intake.update(attributes_for(:intake))
      efile_attrs = attributes_for(:efile_security_information).merge(timezone_offset: format_timezone_offset(timezone_offset))
      unless @intake.tax_returns.last.efile_submissions.any?
        efile_submission = EfileSubmission.create(tax_return: @intake.tax_returns.last, efile_security_information_attributes: efile_attrs)
        begin
          efile_submission.transition_to(:preparing)
        rescue Statesman::GuardFailedError
          Rails.logger.error "Failed to transition EfileSubmission##{efile_submission.id} to :preparing"
        end
      end
    end

    private

    def format_timezone_offset(tz_offset)
      return unless tz_offset.present?

      return (tz_offset.include?("-") || tz_offset.include?("+")) ? tz_offset : "+" + tz_offset
    end
  end
end
