module Questions
  class PersonalInfoController < QuestionsController
    include AnonymousIntakeConcern
    def illustration_path; end

    def tracking_data
      {}
    end
  end
end
