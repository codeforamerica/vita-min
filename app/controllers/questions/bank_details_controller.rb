module Questions
  class BankDetailsController < QuestionsController
    include AuthenticatedClientConcern

    def tracking_data
      {}
    end

    def self.show?(intake)
      intake.refund_direct_deposit_yes?
    end
  end
end
