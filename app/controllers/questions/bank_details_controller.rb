module Questions
  class BankDetailsController < QuestionsController
    def tracking_data
      {}
    end

    def self.show?(intake)
      intake.include_bank_details?
    end
  end
end
