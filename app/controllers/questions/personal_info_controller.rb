module Questions
  class PersonalInfoController < QuestionsController
    def illustration_path; end

    def tracking_data
      {}
    end

    def after_update_success
      # TODO: figure out a better way to do this
      current_intake.assign_vita_partner
    end
  end
end
