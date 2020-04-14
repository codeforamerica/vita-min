module Questions
  class PersonalInfoController < QuestionsController
    skip_before_action :require_sign_in

    def illustration_path; end

    def tracking_data
      {}
    end
  end
end
