module Questions
  class PersonalInfoController < QuestionsController
    def illustration_path; end

    def tracking_data
      {}
    end

    def after_update_success
      unless Client.after_consent.where(intake: current_intake).exists?
        current_intake.assign_vita_partner!
        current_intake.client.update(vita_partner: current_intake.vita_partner)
      end
    end
  end
end
