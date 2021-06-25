module Questions
  class MailingAddressController < QuestionsController
    include AuthenticatedClientConcern

    def tracking_data
      {}
    end
  end
end
