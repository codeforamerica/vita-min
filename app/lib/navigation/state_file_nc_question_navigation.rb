module Navigation
  class StateFileNcQuestionNavigation < Navigation::StateFileBaseQuestionNavigation
    include ControllerNavigation

    SECTIONS = [
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
        Navigation::NavigationStep.new(StateFile::Questions::NcEligibilityController),
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
        Navigation::NavigationStep.new(StateFile::Questions::NcQssInfoController),
        Navigation::NavigationStep.new(StateFile::Questions::NcCountyController),
        Navigation::NavigationStep.new(StateFile::Questions::NcVeteranStatusController),
        Navigation::NavigationStep.new(StateFile::Questions::IncomeReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::UnemploymentController),
        Navigation::RepeatedMultiPageStep.new(
          "retirement_income_deduction",
          [StateFile::Questions::NcRetirementIncomeSubtractionController],
          ->(intake) { intake&.eligible_1099rs&.count }),
        Navigation::NavigationStep.new(StateFile::Questions::NcSubtractionsController),
        Navigation::NavigationStep.new(StateFile::Questions::NcSalesUseTaxController),
        Navigation::NavigationStep.new(StateFile::Questions::FederalExtensionPaymentsController),
        Navigation::NavigationStep.new(StateFile::Questions::NcOutOfCountryController),
        Navigation::NavigationStep.new(StateFile::Questions::ExtensionPaymentsController),
        Navigation::NavigationStep.new(StateFile::Questions::PrimaryStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::SpouseStateIdController),
        Navigation::NavigationStep.new(StateFile::Questions::NcReviewController),
        Navigation::NavigationStep.new(StateFile::Questions::NcTaxesOwedController),
        Navigation::NavigationStep.new(StateFile::Questions::NcTaxRefundController),
        Navigation::NavigationStep.new(StateFile::Questions::EsignDeclarationController), # creates EfileSubmission and transitions to preparing
      ], true, true),
      Navigation::NavigationSection.new("state_file.navigation.section_6", [
        Navigation::NavigationStep.new(StateFile::Questions::SubmissionConfirmationController),
        Navigation::NavigationStep.new(StateFile::Questions::ReturnStatusController),
      ], true, true),
    ].freeze

    def self.controllers
      sections.flat_map(&:controllers)
    end

    def self.pages(visitor_record)
      sections.flat_map { |section| section.pages(visitor_record) }
    end
  end
end
