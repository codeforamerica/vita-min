module Questions
  class EmailVerificationController < QuestionsController
    include AnonymousIntakeConcern
    before_action :send_verification_code, only: [:edit]

    layout "intake"

    def self.show?(intake)
      intake.email_address.present? && intake.email_notification_opt_in_yes? && !intake.email_address_verified_at.present?
    end

    def self.i18n_base_path
      "views.questions.verification"
    end

    private

    def send_verification_code
      RequestVerificationCodeEmailJob.perform_later(
        client_id: current_intake.client_id,
        email_address: current_intake.email_address,
        locale: I18n.locale,
        visitor_id: current_intake.visitor_id,
        service_type: :gyr
      )
    end

    def illustration_path
      "contact-preference.svg"
    end
  end
end
