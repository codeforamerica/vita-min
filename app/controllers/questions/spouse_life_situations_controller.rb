module Questions
  class SpouseLifeSituationsController < QuestionsController
    include AuthenticatedClientConcern

    def self.show?(intake)
      intake.filing_joint_yes?
    end
  end
end