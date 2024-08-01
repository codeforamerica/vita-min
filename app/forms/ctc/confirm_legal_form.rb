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
                       :timezone
    set_attributes_for :recaptcha, :recaptcha_score, :recaptcha_action

    validates :consented_to_legal, acceptance: { accept: 'yes', message: ->(_object, _data) { I18n.t("views.ctc.questions.confirm_legal.error") }}
    validates_presence_of :device_id, :user_agent, :browser_language, :platform, :timezone_offset, :client_system_time, :ip_address, :timezone

    def save
      intake_attributes = attributes_for(:intake)
      intake_attributes[:completed_at] = DateTime.current unless @intake.completed_at.present?
      @intake.update(intake_attributes)
      efile_attrs = attributes_for(:efile_security_information)

      if attributes_for(:recaptcha)[:recaptcha_score].present?
        @intake.client.recaptcha_scores.create(
          score: attributes_for(:recaptcha)[:recaptcha_score],
          action: attributes_for(:recaptcha)[:recaptcha_action]
        )
      end

      unless @intake.tax_returns.last.efile_submissions.any?
        EfileSecurityInformation.create(efile_attrs.merge(client: @intake.client))

        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: @intake.tax_returns.last, dependents: @intake.dependents)
        efile_submission = EfileSubmission.create(
          tax_return: @intake.tax_returns.last,
          claimed_eitc: benefits_eligibility.eitc_amount&.positive?
        )
        begin
          # Transitioning will no longer work because we've removed CTC code from the efile submission state machine
          # efile_submission.transition_to(:preparing)
        rescue Statesman::GuardFailedError
          Rails.logger.error "Failed to transition EfileSubmission##{efile_submission.id} to :preparing"
        end
      end
    end
  end
end
