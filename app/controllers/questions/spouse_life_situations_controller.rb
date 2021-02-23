module Questions
  class SpouseLifeSituationsController < QuestionsController
    def self.show?(intake)
      intake.filing_joint_yes?
    end
    
    def illustration_path; end
  end
end