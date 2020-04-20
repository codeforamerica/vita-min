module Questions
  class SpouseEmailAddressController < QuestionsController
    skip_before_action :require_sign_in

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
