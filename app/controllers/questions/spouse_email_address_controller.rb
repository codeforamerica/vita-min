module Questions
  class SpouseEmailAddressController < QuestionsController
    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def tracking_data
      {}
    end

    def illustration_path
      "email-address.svg"
    end
  end
end
