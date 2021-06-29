module Questions
  class PhoneNumberController < QuestionsController
    include AnonymousIntakeConcern
    def tracking_data
      {}
    end
  end
end
