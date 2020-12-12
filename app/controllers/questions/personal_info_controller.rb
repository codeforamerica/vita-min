module Questions
  class PersonalInfoController < QuestionsController
    def illustration_path; end

    def tracking_data
      {}
    end

    def after_update_success
      unless Client.after_consent.where(intake: current_intake).exists?
        ClientRouter.route(current_intake.client)
      end
    end
  end
end
