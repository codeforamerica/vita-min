module Navigation
  class StateFileNjQuestionNavigation < Navigation::StateFileBaseQuestionNavigation
    include ControllerNavigation

    SECTIONS = [
      Navigation::NavigationSection.new("state_file.navigation.section_1", [
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
                                          # Federal info does not show to users
                                          Navigation::NavigationStep.new(StateFile::Questions::FederalInfoController),
                                          Navigation::NavigationStep.new(StateFile::Questions::DataTransferOffboardingController, false),
                                          Navigation::NavigationStep.new(StateFile::Questions::IncomeReviewController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjEligibilityHealthInsuranceController),
                                          Navigation::NavigationStep.new(StateFile::Questions::EligibilityOffboardingController, false),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjYearOfDeathController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjCountyController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjMunicipalityController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjDisabledExemptionController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjVeteransExemptionController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjCollegeDependentsExemptionController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjDependentsHealthInsuranceController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjMedicalExpensesController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjHouseholdRentOwnController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjHomeownerEligibilityController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjHomeownerPropertyTaxController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjHomeownerPropertyTaxWorksheetController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjTenantEligibilityController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjTenantRentPaidController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjTenantPropertyTaxWorksheetController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjIneligiblePropertyTaxController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjEstimatedTaxPaymentsController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjEitcQualifyingChildController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjSalesUseTaxController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjGubernatorialElectionsController),
                                          Navigation::NavigationStep.new(StateFile::Questions::PrimaryStateIdController),
                                          Navigation::NavigationStep.new(StateFile::Questions::SpouseStateIdController),
                                          Navigation::NavigationStep.new(StateFile::Questions::TaxesOwedController),
                                          Navigation::NavigationStep.new(StateFile::Questions::TaxRefundController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjReviewController),
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
