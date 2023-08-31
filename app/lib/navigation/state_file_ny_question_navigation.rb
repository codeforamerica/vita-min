module Navigation
  class StateFileNyQuestionNavigation
    include ControllerNavigation

    FLOW = [
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::FederalDependentsController,
      StateFile::Questions::Ny201Controller,
      StateFile::Questions::Ny214Controller,
      StateFile::Questions::SubmitReturnController
    ].freeze

    def self.intake_class
      StateFileNyIntake
    end
  end
end
