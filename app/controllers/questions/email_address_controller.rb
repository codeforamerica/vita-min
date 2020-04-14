module Questions
  class EmailAddressController < QuestionsController
    skip_before_action :require_sign_in

    def tracking_data
      {}
    end
  end
end
