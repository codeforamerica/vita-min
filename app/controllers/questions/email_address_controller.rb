module Questions
  class EmailAddressController < QuestionsController
    include AnonymousIntakeConcern

    def self.show?(intake)
      intake.email_address.blank? && intake.email_notification_opt_in_yes?
    end
  end
end
