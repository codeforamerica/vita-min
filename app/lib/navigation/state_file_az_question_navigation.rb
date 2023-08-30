module Navigation
  class StateFileAzQuestionNavigation
    include ControllerNavigation

    FLOW = [
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::SubmitReturnController
    ].freeze

    def self.intake_class
      StateFileAzIntake
    end
  end
end
