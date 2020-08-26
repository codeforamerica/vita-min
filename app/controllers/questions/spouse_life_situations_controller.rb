module Questions
  class SpouseLifeSituationsController < QuestionsController
    def self.show?(intake)
      intake.filing_joint_yes?
    end

    def illustration_path
      "life-situations.svg"
    end
  end
end