module Questions
  class MailingAddressController < QuestionsController
    include AuthenticatedClientConcern

    def tracking_data
      {}
    end

    def next_path
      next_step = Navigation::DocumentNavigation.first_for_intake(current_intake)
      document_path(next_step.to_param)
    end
  end
end
