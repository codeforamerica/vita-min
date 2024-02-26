module Questions
  class PhoneNumberCanReceiveTextsController < QuestionsController
    include AnonymousIntakeConcern

    layout "yes_no_question"

    def self.show?(intake)
      intake.phone_number.present? && intake.sms_notification_opt_in_yes?
    end

    def illustration_path
      "contact-preference.svg"
    end

    private

    def has_unsure_option?
      false
    end
  end
end