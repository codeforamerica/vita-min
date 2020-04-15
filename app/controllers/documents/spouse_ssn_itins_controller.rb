module Documents
  class SpouseSsnItinsController < DocumentUploadQuestionController
    def self.show?(intake)
      intake.filing_joint_yes?
    end
  end
end
