module Navigation
  class StateFileNyQuestionNavigation
    include ControllerNavigation

    NAVIGATION = [
      Navigation::NavigationSection("", [
        Navigation::NavigationStep(StateFile::Questions::LandingPageController, false, false)
      ]),
      Navigation::NavigationSection("Section 1: Can you use this tool", [
        Navigation::NavigationStep(StateFile::Questions::EligibilityResidenceController),
        Navigation::NavigationStep(StateFile::Questions::EligibilityOutOfStateIncomeController),
        Navigation::NavigationStep(StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController),
        Navigation::NavigationStep(StateFile::Questions::EligibilityOffboardingController),
        Navigation::NavigationStep(StateFile::Questions::EligibleController),
      ]),
      Navigation::NavigationSection("Section 2: Create account", [
        Navigation::NavigationStep(StateFile::Questions::ContactPreferenceController),
        Navigation::NavigationStep(StateFile::Questions::PhoneNumberController),
        Navigation::NavigationStep(StateFile::Questions::EmailAddressController, false),
        Navigation::NavigationStep(StateFile::Questions::VerificationCodeController),
        Navigation::NavigationStep(StateFile::Questions::CodeVerifiedController),
      ]),
      Navigation::NavigationSection("Section 3: Terms and conditions", [
        Navigation::NavigationStep(StateFile::Questions::TermsAndConditionsController, false, false),
        Navigation::NavigationStep(StateFile::Questions::DeclinedTermsAndConditionsController, false, false),
      ]),
      Navigation::NavigationSection("Section 4: Transfer your data", [
        Navigation::NavigationStep(StateFile::Questions::InitiateDataTransferController),
        Navigation::NavigationStep(StateFile::Questions::CanceledDataTransferController, false), # show? false
        Navigation::NavigationStep(StateFile::Questions::WaitingToLoadDataController),
      ]),
      Navigation::NavigationSection("Section 5: Complete your state tax return", [
        Navigation::NavigationStep(StateFile::Questions::DataReviewController),
        Navigation::NavigationStep(StateFile::Questions::FederalInfoController),
        Navigation::NavigationStep(StateFile::Questions::DataTransferOffboardingController),
        Navigation::NavigationStep(StateFile::Questions::NameDobController),
        Navigation::NavigationStep(StateFile::Questions::NycResidencyController),
        Navigation::NavigationStep(StateFile::Questions::NyPermanentAddressController),
        Navigation::NavigationStep(StateFile::Questions::NyCountyController),
        Navigation::NavigationStep(StateFile::Questions::NySchoolDistrictController),
        Navigation::NavigationStep(StateFile::Questions::NySalesUseTaxController),
        Navigation::NavigationStep(StateFile::Questions::NyPrimaryStateIdController),
        Navigation::NavigationStep(StateFile::Questions::NySpouseStateIdController),
        Navigation::NavigationStep(StateFile::Questions::UnemploymentController),
        Navigation::NavigationStep(StateFile::Questions::NyReviewController),
        Navigation::NavigationStep(StateFile::Questions::TaxesOwedController),
        Navigation::NavigationStep(StateFile::Questions::TaxRefundController),
        # XXXX
        Navigation::NavigationStep(StateFile::Questions::EsignDeclarationController), # creates EfileSubmission and transitions to preparing
        Navigation::NavigationStep(StateFile::Questions::SubmissionConfirmationController),
        Navigation::NavigationStep(StateFile::Questions::EsignDeclarationController), # creates EfileSubmission and transitions to preparing
      ]),
      Navigation::NavigationSection("Section 6: Submut your state taxes", [



      StateFile::Questions::SubmissionConfirmationController,
      StateFile::Questions::ReturnStatusController,
    ]

    FLOW = [
      StateFile::Questions::LandingPageController, # creates state_intake (StartIntakeConcern)
      StateFile::Questions::EligibilityResidenceController,
      StateFile::Questions::EligibilityOutOfStateIncomeController,
      StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController,
      StateFile::Questions::EligibilityOffboardingController,
      StateFile::Questions::EligibleController,
      StateFile::Questions::ContactPreferenceController,
      StateFile::Questions::PhoneNumberController,
      StateFile::Questions::EmailAddressController,
      StateFile::Questions::VerificationCodeController,
      StateFile::Questions::CodeVerifiedController,
      StateFile::Questions::TermsAndConditionsController,
      StateFile::Questions::DeclinedTermsAndConditionsController,
      StateFile::Questions::InitiateDataTransferController,
      StateFile::Questions::CanceledDataTransferController, # show? false
      StateFile::Questions::WaitingToLoadDataController,
      StateFile::Questions::DataReviewController,
      StateFile::Questions::FederalInfoController,
      StateFile::Questions::DataTransferOffboardingController,
      StateFile::Questions::NameDobController,
      StateFile::Questions::NycResidencyController,
      StateFile::Questions::NyPermanentAddressController,
      StateFile::Questions::NyCountyController,
      StateFile::Questions::NySchoolDistrictController,
      StateFile::Questions::NySalesUseTaxController,
      StateFile::Questions::NyPrimaryStateIdController,
      StateFile::Questions::NySpouseStateIdController,
      StateFile::Questions::UnemploymentController,
      StateFile::Questions::NyReviewController,
      StateFile::Questions::TaxesOwedController,
      StateFile::Questions::TaxRefundController,
      StateFile::Questions::EsignDeclarationController, # creates EfileSubmission and transitions to preparing
      StateFile::Questions::SubmissionConfirmationController,
      StateFile::Questions::ReturnStatusController,
    ].freeze

    def self.intake_class
      StateFileNyIntake
    end
  end
end
