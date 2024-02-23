module Navigation
  class StateFileNyQuestionNavigation
    include ControllerNavigation

    SECTIONS = [
      Navigation::NavigationSection.new("", [
        Navigation::NavigationStep.new(StateFile::Questions::LandingPageController, false, false)
      ]),
      Navigation::NavigationSection.new("Section 1: Can you use this tool", [
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityResidenceController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityOutOfStateIncomeController),
        Navigation::NavigationStep.new(StateFile::Questions::NyEligibilityCollegeSavingsWithdrawalController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibilityOffboardingController),
        Navigation::NavigationStep.new(StateFile::Questions::EligibleController),
      ]),
      Navigation::NavigationSection.new("Section 2: Create account", [
        Navigation::NavigationStep.new(StateFile::Questions::ContactPreferenceController),
        Navigation::NavigationStep.new(StateFile::Questions::PhoneNumberController),
        Navigation::NavigationStep.new(StateFile::Questions::EmailAddressController, false),
        Navigation::NavigationStep.new(StateFile::Questions::VerificationCodeController),
        Navigation::NavigationStep.new(StateFile::Questions::CodeVerifiedController),
      ]),
      Navigation::NavigationSection.new("Section 3: Terms and conditions", [
        Navigation::NavigationStep.new(StateFile::Questions::TermsAndConditionsController, false, false),
        Navigation::NavigationStep.new(StateFile::Questions::DeclinedTermsAndConditionsController, false, false),
      ]),
      Navigation::NavigationSection.new("Section 4: Transfer your data", [
        Navigation::NavigationStep.new(StateFile::Questions::InitiateDataTransferController),
        Navigation::NavigationStep.new(StateFile::Questions::CanceledDataTransferController, false), # show? false
        Navigation::NavigationStep.new(StateFile::Questions::WaitingToLoadDataController),
      ]),
      Navigation::NavigationSection.new("Section 5: Complete your state tax return", [
        Navigation::NavigationStep.new(StateFile::Questions::DataReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::FederalInfoController),
        Navigation::NavigationStep.new(StateFile::Questions::DataTransferOffboardingController),
        Navigation::NavigationStep.new(StateFile::Questions::NameDobController),
        Navigation::NavigationStep.new(StateFile::Questions::NycResidencyController),
        Navigation::NavigationStep.new(StateFile::Questions::NyPermanentAddressController),
        Navigation::NavigationStep.new(StateFile::Questions::NyCountyController),
        Navigation::NavigationStep.new(StateFile::Questions::NySchoolDistrictController),
        Navigation::NavigationStep.new(StateFile::Questions::NySalesUseTaxController),
        Navigation::NavigationStep.new(StateFile::Questions::NyPrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::NySpouseStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::UnemploymentController),
        Navigation::NavigationStep.new(StateFile::Questions::NyReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::TaxesOwedController),
        Navigation::NavigationStep.new(StateFile::Questions::TaxRefundController),
        Navigation::NavigationStep.new(StateFile::Questions::EsignDeclarationController), # creates EfileSubmission and transitions to preparing
      ]),
      Navigation::NavigationSection.new("Section 6: Submit your state taxes", [
        Navigation::NavigationStep.new(StateFile::Questions::SubmissionConfirmationController),
        Navigation::NavigationStep.new(StateFile::Questions::ReturnStatusController),
      ]),
    ].freeze
    FLOW = SECTIONS.map(&:controllers).flatten.freeze

    def self.get_section(controller)
      SECTIONS.detect { |section| section.controllers.select { |c| c == controller }}
    end

    def self.get_progress(controller)
      SECTIONS.lazy.map { |s| s.get_progress(controller) }.detect.first

    end

    def self.intake_class
      StateFileNyIntake
    end
  end
end
