module Navigation
  class StateFileAzQuestionNavigation
    include ControllerNavigation

    FLOW = [
      StateFile::Questions::LandingPageController,
      StateFile::Questions::SetUpAccountController,
      StateFile::Questions::LoginController,
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::FederalDependentsController,
      StateFile::Questions::DobController,
      StateFile::Questions::SubmitReturnController,
      StateFile::Questions::ConfirmationController
    ].freeze

    def self.intake_class
      StateFileAzIntake
    end
  end
end
