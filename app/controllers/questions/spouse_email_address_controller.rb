module Questions
  class SpouseEmailAddressController < QuestionsController
    include AuthenticatedClientConcern

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
