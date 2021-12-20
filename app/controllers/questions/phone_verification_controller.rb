module Questions
  class PhoneVerificationController < QuestionsController
    include AnonymousIntakeConcern
    before_action :send_verification_code, only: [:edit]

    layout "intake"

    def self.show?(intake)
      intake.sms_phone_number.present? && intake.sms_notification_opt_in_yes? && !intake.sms_phone_number_verified_at.present?
    end

    def self.i18n_base_path #what is this for??
      "views.questions.verification"
    end

    private

    def send_verification_code
      RequestVerificationCodeTextMessageJob.perform_later(
        phone_number: current_intake.sms_phone_number,
        locale: I18n.locale,
        visitor_id: current_intake.visitor_id,
        client_id: current_intake.client_id,
        service_type: :gyr
      )
    end

    def illustration_path
      "contact-preference.svg"
    end
  end
end