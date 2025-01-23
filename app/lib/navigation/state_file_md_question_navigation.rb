module Navigation
  class StateFileMdQuestionNavigation < Navigation::StateFileBaseQuestionNavigation
    include ControllerNavigation

    SECTIONS = [
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
        Navigation::NavigationStep.new(StateFile::Questions::MdEligibilityFilingStatusController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibleController),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_2", [
        Navigation::NavigationStep.new(StateFile::Questions::ContactPreferenceController),
        # Phone number only shows if the contact pref is text, which only shows if the text pref feature is toggled on by Flipper
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
        Navigation::NavigationStep.new(StateFile::Questions::PostDataTransferController, false),
        Navigation::NavigationStep.new(StateFile::Questions::MdPermanentAddressController),
        # Federal info does not show to users
        Navigation::NavigationStep.new(StateFile::Questions::FederalInfoController),
        Navigation::NavigationStep.new(StateFile::Questions::MdCountyController),
        Navigation::NavigationStep.new(StateFile::Questions::DataTransferOffboardingController, false),
        Navigation::NavigationStep.new(StateFile::Questions::IncomeReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::UnemploymentController),
        Navigation::NavigationStep.new(StateFile::Questions::MdSocialSecurityBenefitsController),
        Navigation::NavigationStep.new(StateFile::Questions::MdTwoIncomeSubtractionsController),
        Navigation::NavigationStep.new(StateFile::Questions::PrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::SpouseStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::MdReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::TaxesOwedController),
        Navigation::NavigationStep.new(StateFile::Questions::MdTaxRefundController),
        Navigation::NavigationStep.new(StateFile::Questions::MdHadHealthInsuranceController),
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
