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
      StateFile::Questions::InitiateDataTransferController,
      StateFile::Questions::WaitingToLoadDataController,
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::FederalDependentsController,
      StateFile::Questions::NameDobController,
      StateFile::Questions::NyPermanentAddressController,
      StateFile::Questions::NyCountyController,
      StateFile::Questions::NySchoolDistrictController,
      StateFile::Questions::NySalesUseTaxController,
      StateFile::Questions::Ny201Controller,
      StateFile::Questions::Ny214Controller,
      StateFile::Questions::UnemploymentController,
      StateFile::Questions::SubmitReturnController,
      StateFile::Questions::SubmissionConfirmationController,
    ].freeze

    def self.intake_class
      StateFileNyIntake
    end
  end
end
