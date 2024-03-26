module Navigation
  class StateFileNyQuestionNavigation
    include ControllerNavigation
    include Navigation::StateFileBaseQuestionNavigationMixin

    SECTIONS = [
      Navigation::NavigationSection.new(nil, [
        Navigation::NavigationStep.new(StateFile::Questions::LandingPageController, false)
      ], false),
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityResidenceController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityOutOfStateIncomeController),
        Navigation::NavigationStep.new(StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityOffboardingController, false),
        Navigation::NavigationStep.new(StateFile::Questions::EligibleController, true, StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_2", [
        Navigation::NavigationStep.new(StateFile::Questions::ContactPreferenceController, true, StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController),
        Navigation::NavigationStep.new(StateFile::Questions::PhoneNumberController, true, StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController),
        Navigation::NavigationStep.new(StateFile::Questions::EmailAddressController, true, StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController),
        Navigation::NavigationStep.new(StateFile::Questions::VerificationCodeController, true, StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController),
        Navigation::NavigationStep.new(StateFile::Questions::CodeVerifiedController),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_3", [
        Navigation::NavigationStep.new(StateFile::Questions::TermsAndConditionsController),
        Navigation::NavigationStep.new(StateFile::Questions::DeclinedTermsAndConditionsController, false),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_4", [
        Navigation::NavigationStep.new(StateFile::Questions::InitiateDataTransferController, true, StateFile::Questions::TermsAndConditionsController),
        Navigation::NavigationStep.new(StateFile::Questions::CanceledDataTransferController, false), # show? false
        Navigation::NavigationStep.new(StateFile::Questions::WaitingToLoadDataController, true, StateFile::Questions::InitiateDataTransferController),
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_5", [
        Navigation::NavigationStep.new(StateFile::Questions::DataReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::FederalInfoController),
        Navigation::NavigationStep.new(StateFile::Questions::DataTransferOffboardingController, false),
        Navigation::NavigationStep.new(StateFile::Questions::NameDobController, true, StateFile::Questions::DataReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::NycResidencyController),
        Navigation::NavigationStep.new(StateFile::Questions::NyPermanentAddressController),
        Navigation::NavigationStep.new(StateFile::Questions::NyCountyController),
        Navigation::NavigationStep.new(StateFile::Questions::NySchoolDistrictController),
        Navigation::NavigationStep.new(StateFile::Questions::W2Controller),
        Navigation::NavigationStep.new(StateFile::Questions::NySalesUseTaxController),
        Navigation::NavigationStep.new(StateFile::Questions::NyPrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::NySpouseStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::NyThirdPartyDesigneeController),
        Navigation::NavigationStep.new(StateFile::Questions::UnemploymentController, true, StateFile::Questions::NyPrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::NyReviewController, true, StateFile::Questions::NyPrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::TaxesOwedController, true, StateFile::Questions::NyPrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::TaxRefundController, true, StateFile::Questions::NyReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::EsignDeclarationController, true, StateFile::Questions::NyReviewController), # creates EfileSubmission and transitions to preparing
      ]),
      Navigation::NavigationSection.new("state_file.navigation.section_6", [
        Navigation::NavigationStep.new(StateFile::Questions::SubmissionConfirmationController),
        Navigation::NavigationStep.new(StateFile::Questions::ReturnStatusController, true, StateFile::Questions::NyReviewController),
      ]),
    ].freeze
    FLOW = SECTIONS.map(&:controllers).flatten.freeze

    def self.intake_class
      StateFileNyIntake
    end
  end
end
