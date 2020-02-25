module Questions
  class SpouseConsentController < ConsentController
    def self.show?(intake)
      intake.filing_joint_yes?
    end
  end
end
