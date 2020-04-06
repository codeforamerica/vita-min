module Questions
  class MailingAddressController < QuestionsController
    def tracking_data
      {
        mailing_address_same_as_idme_address: current_intake.address_matches_primary_user_address?
      }
    end
  end
end
