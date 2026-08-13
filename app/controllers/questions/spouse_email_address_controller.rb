module Questions
  class SpouseEmailAddressController < QuestionsController
    include AuthenticatedClientConcern

    def self.show?(intake)
      # don't show if Conditions:
      # If client answers “NO” to “As of December 31, {filing year}, were you legally married?”
      # and “YES” to “As of December 31, {filing year}, were you widowed?”
      intake.filing_joint_yes? && !(intake.widowed_yes? && intake.married_last_day_of_year_no?)

    end

    def tracking_data
      {}
    end

    def illustration_path
      "email-address.svg"
    end
  end
end
