module Questions
  class PhoneNumberController < QuestionsController
    skip_before_action :require_sign_in

    def tracking_data
      {}
    end
  end
end
