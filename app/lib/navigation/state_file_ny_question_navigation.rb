module Navigation
  class StateFileNyQuestionNavigation
    include ControllerNavigation

    FLOW = [
      StateFile::Questions::LandingPageController,
      StateFile::Questions::ContactPreferenceController, # creates state_intake (StartIntakeConcern)
      StateFile::Questions::PhoneNumberController,
      StateFile::Questions::EmailAddressController,
      StateFile::Questions::VerificationCodeController,
      StateFile::Questions::CodeVerifiedController,
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::FederalDependentsController,
      StateFile::Questions::DobController,
      StateFile::Questions::NyPermanentAddressController,
      StateFile::Questions::NyOutOfStatePurchasesController,
      StateFile::Questions::Ny201Controller,
      StateFile::Questions::Ny214Controller,
      StateFile::Questions::SubmitReturnController,
      StateFile::Questions::ConfirmationController
    ].freeze

    def self.intake_class
      StateFileNyIntake
    end
  end
end
