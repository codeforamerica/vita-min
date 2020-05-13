module Questions
  class BankDetailsController < TicketedQuestionsController
    def illustration_path; end

    def tracking_data
      {}
    end

    def self.show?(intake)
      intake.include_bank_details?
    end
  end
end
