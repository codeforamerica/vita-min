module Questions
  class EmailAddressController < QuestionsController
    include AnonymousIntakeConcern
    def after_update_success
      current_intake.update(email_notification_opt_in: "yes")
    end
  end
end
