module Navigation
  class StateFileIdQuestionNavigation < Navigation::StateFileBaseQuestionNavigation
    include ControllerNavigation

    SECTIONS = [
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
        Navigation::NavigationStep.new(StateFile::Questions::IdEligibilityResidenceController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityOffboardingController, false),
        Navigation::NavigationStep.new(StateFile::Questions::EligibleController),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_2", [
        Navigation::NavigationStep.new(StateFile::Questions::ContactPreferenceController),
        Navigation::NavigationStep.new(StateFile::Questions::PhoneNumberController),
        Navigation::NavigationStep.new(StateFile::Questions::EmailAddressController),
        Navigation::NavigationStep.new(StateFile::Questions::VerificationCodeController),
        Navigation::NavigationStep.new(StateFile::Questions::CodeVerifiedController),
        Navigation::NavigationStep.new(StateFile::Questions::NotificationPreferencesController),
        Navigation::NavigationStep.new(StateFile::Questions::SmsTermsController),
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
        Navigation::NavigationStep.new(StateFile::Questions::PostDataTransferController),
        Navigation::NavigationStep.new(StateFile::Questions::FederalInfoController),
        Navigation::NavigationStep.new(StateFile::Questions::DataTransferOffboardingController, false),
        Navigation::NavigationStep.new(StateFile::Questions::IncomeReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::UnemploymentController),
        Navigation::NavigationStep.new(StateFile::Questions::IdDisabilityController),
        Navigation::NavigationStep.new(StateFile::Questions::IdRetirementAndPensionIncomeController),
        Navigation::NavigationStep.new(StateFile::Questions::IdHealthInsurancePremiumController),
        Navigation::NavigationStep.new(StateFile::Questions::IdGroceryCreditController),
        Navigation::NavigationStep.new(StateFile::Questions::IdGroceryCreditReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::IdSalesUseTaxController),
        Navigation::NavigationStep.new(StateFile::Questions::ExtensionPaymentsController),
        Navigation::NavigationStep.new(StateFile::Questions::IdPermanentBuildingFundController),
        Navigation::NavigationStep.new(StateFile::Questions::PrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::SpouseStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::IdReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::IdDonationsController, false), # show? false
        Navigation::NavigationStep.new(StateFile::Questions::TaxesOwedController),
        Navigation::NavigationStep.new(StateFile::Questions::TaxRefundController),
        Navigation::NavigationStep.new(StateFile::Questions::EsignDeclarationController), # creates EfileSubmission and transitions to preparing
      ], true, true),
      Navigation::NavigationSection.new("state_file.navigation.section_6", [
        Navigation::NavigationStep.new(StateFile::Questions::SubmissionConfirmationController),
        Navigation::NavigationStep.new(StateFile::Questions::ReturnStatusController),
      ], true, true),
    ].freeze
    FLOW = SECTIONS.map(&:controllers).flatten.freeze
  end
end
