module Navigation
  class StateFileAzQuestionNavigation
    include ControllerNavigation
    include Navigation::StateFileBaseQuestionNavigationMixin

    SECTIONS = [
      Navigation::NavigationSection.new("", [
        Navigation::NavigationStep.new(StateFile::Questions::LandingPageController, false)
      ], false),
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityResidenceController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityOutOfStateIncomeController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityOffboardingController, false),
        Navigation::NavigationStep.new(StateFile::Questions::EligibleController),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_2", [
        Navigation::NavigationStep.new(StateFile::Questions::ContactPreferenceController),
        Navigation::NavigationStep.new(StateFile::Questions::PhoneNumberController),
        Navigation::NavigationStep.new(StateFile::Questions::EmailAddressController),
        Navigation::NavigationStep.new(StateFile::Questions::VerificationCodeController),
        Navigation::NavigationStep.new(StateFile::Questions::CodeVerifiedController),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_3", [
        Navigation::NavigationStep.new(StateFile::Questions::TermsAndConditionsController),
        Navigation::NavigationStep.new(StateFile::Questions::DeclinedTermsAndConditionsController, false),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_4", [
        Navigation::NavigationStep.new(StateFile::Questions::InitiateDataTransferController),
        Navigation::NavigationStep.new(StateFile::Questions::CanceledDataTransferController, false), # show? false
        Navigation::NavigationStep.new(StateFile::Questions::WaitingToLoadDataController),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_5", [
        Navigation::NavigationStep.new(StateFile::Questions::DataReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::FederalInfoController),
        Navigation::NavigationStep.new(StateFile::Questions::DataTransferOffboardingController, false),
        Navigation::NavigationStep.new(StateFile::Questions::NameDobController),
        Navigation::NavigationStep.new(StateFile::Questions::AzSeniorDependentsController),
        Navigation::NavigationStep.new(StateFile::Questions::AzPriorLastNamesController),
        Navigation::NavigationStep.new(StateFile::Questions::W2Controller),
        Navigation::NavigationStep.new(StateFile::Questions::UnemploymentController),
        Navigation::NavigationStep.new(StateFile::Questions::AzStateCreditsController),
        Navigation::NavigationStep.new(StateFile::Questions::AzCharitableContributionsController),
        Navigation::NavigationStep.new(StateFile::Questions::AzExciseCreditController),
        Navigation::NavigationStep.new(StateFile::Questions::AzPrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::AzSpouseStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::AzReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::TaxesOwedController),
        Navigation::NavigationStep.new(StateFile::Questions::TaxRefundController),
        Navigation::NavigationStep.new(StateFile::Questions::EsignDeclarationController), # creates EfileSubmission and transitions to preparing
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_6", [
        Navigation::NavigationStep.new(StateFile::Questions::SubmissionConfirmationController),
        Navigation::NavigationStep.new(StateFile::Questions::ReturnStatusController),
      ]),
    ].freeze
    FLOW = SECTIONS.map(&:controllers).flatten.freeze
  end
end
