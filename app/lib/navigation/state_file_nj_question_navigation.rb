module Navigation
  class StateFileNjQuestionNavigation < Navigation::StateFileBaseQuestionNavigation
    include ControllerNavigation

    def self.show_progress?(controller_class)
      section = get_section(controller_class)
      section && section.increment_step?
    end

    SECTIONS = [
      Navigation::NavigationSection.new("", [
                                          Navigation::NavigationStep.new(StateFile::Questions::EligibleController),
                                          Navigation::NavigationStep.new(StateFile::Questions::ContactPreferenceController),
                                          # Phone number only shows if the contact pref is text, which only shows if the text pref feature is toggled on by Flipper
                                          Navigation::NavigationStep.new(StateFile::Questions::PhoneNumberController),
                                          Navigation::NavigationStep.new(StateFile::Questions::EmailAddressController),
                                          Navigation::NavigationStep.new(StateFile::Questions::VerificationCodeController),
                                          Navigation::NavigationStep.new(StateFile::Questions::CodeVerifiedController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NotificationPreferencesController),
                                          Navigation::NavigationStep.new(StateFile::Questions::SmsTermsController),
                                          Navigation::NavigationStep.new(StateFile::Questions::TermsAndConditionsController),
                                          Navigation::NavigationStep.new(StateFile::Questions::DeclinedTermsAndConditionsController, false),
                                          Navigation::NavigationStep.new(StateFile::Questions::InitiateDataTransferController),
                                          Navigation::NavigationStep.new(StateFile::Questions::CanceledDataTransferController, false), # show? false
                                          Navigation::NavigationStep.new(StateFile::Questions::WaitingToLoadDataController),
                                          Navigation::NavigationStep.new(StateFile::Questions::PostDataTransferController),
                                          # Federal info does not show to users
                                          Navigation::NavigationStep.new(StateFile::Questions::FederalInfoController),
                                          Navigation::NavigationStep.new(StateFile::Questions::DataTransferOffboardingController, false),
                                        ], false),
      Navigation::NavigationSection.new("state_file.navigation.nj.section_1", [
                                          Navigation::NavigationStep.new(StateFile::Questions::IncomeReviewController), # line 15-27, but intentionally moved up for eligibility checks
                                          Navigation::NavigationStep.new(StateFile::Questions::W2Controller),
                                          Navigation::RepeatedMultiPageStep.new(
                                            "retirement_income_deduction",
                                            [StateFile::Questions::NjRetirementIncomeSourceController],
                                            ->(intake) { intake&.eligible_1099rs&.count }),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjRetirementWarningController),
                                        ]),
      Navigation::NavigationSection.new("state_file.navigation.nj.section_2", [
                                          Navigation::NavigationStep.new(StateFile::Questions::NjEligibilityHealthInsuranceController),
                                          Navigation::NavigationStep.new(StateFile::Questions::EligibilityOffboardingController, false),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjYearOfDeathController), # Line 5
                                          Navigation::NavigationStep.new(StateFile::Questions::NjCountyMunicipalityController), # header
                                          Navigation::NavigationStep.new(StateFile::Questions::NjDisabledExemptionController), # Line 8
                                          Navigation::NavigationStep.new(StateFile::Questions::NjVeteransExemptionController), # Line 9
                                          Navigation::NavigationStep.new(StateFile::Questions::NjCollegeDependentsExemptionController), # Line 13
                                          Navigation::NavigationStep.new(StateFile::Questions::NjDependentsHealthInsuranceController), # Line 14
                                        ]),
      Navigation::NavigationSection.new("state_file.navigation.nj.section_3", [
                                          Navigation::NavigationStep.new(StateFile::Questions::NjMedicalExpensesController), # Line 31
                                          Navigation::NavigationStep.new(StateFile::Questions::NjEitcQualifyingChildController), # Line 58, intentionally moved up to be in the context of other credits and deductions, and to ensure there is a consistent page after the property taxes section.
                                          Navigation::NavigationStep.new(StateFile::Questions::NjHouseholdRentOwnController), # Line 40b
                                          Navigation::NavigationStep.new(StateFile::Questions::NjHomeownerEligibilityController), # Line 40a
                                          Navigation::NavigationStep.new(StateFile::Questions::NjTenantEligibilityController), # Line 40a
                                          Navigation::NavigationStep.new(StateFile::Questions::NjIneligiblePropertyTaxController), # Line 40a
                                          Navigation::NavigationStep.new(StateFile::Questions::NjHomeownerPropertyTaxWorksheetController), # Line 40a
                                          Navigation::NavigationStep.new(StateFile::Questions::NjHomeownerPropertyTaxController), # Line 40a
                                          Navigation::NavigationStep.new(StateFile::Questions::NjTenantPropertyTaxWorksheetController), # Line 40a
                                          Navigation::NavigationStep.new(StateFile::Questions::NjTenantRentPaidController), # Line 40a
                                          # question after property taxes set in NjPropertyTaxFlowOffRamp
                                        ]),
      Navigation::NavigationSection.new(I18n.t("state_file.navigation.nj.section_4", filing_year: MultiTenantService.statefile.current_tax_year), [
                                          Navigation::NavigationStep.new(StateFile::Questions::NjSalesUseTaxController), # Line 51
                                          Navigation::NavigationStep.new(StateFile::Questions::NjEstimatedTaxPaymentsController), # Line 57
                                        ]),
      Navigation::NavigationSection.new("state_file.navigation.nj.section_5", [
                                          Navigation::NavigationStep.new(StateFile::Questions::PrimaryStateIdController), # Footer
                                          Navigation::NavigationStep.new(StateFile::Questions::SpouseStateIdController), # Footer
                                          Navigation::NavigationStep.new(StateFile::Questions::NjReviewController),
                                          Navigation::NavigationStep.new(StateFile::Questions::TaxesOwedController),
                                          Navigation::NavigationStep.new(StateFile::Questions::TaxRefundController),
                                          Navigation::NavigationStep.new(StateFile::Questions::NjGubernatorialElectionsController),
                                          Navigation::NavigationStep.new(StateFile::Questions::EsignDeclarationController), # creates EfileSubmission and transitions to preparing
                                        ]),
      Navigation::NavigationSection.new("", [
                                          Navigation::NavigationStep.new(StateFile::Questions::SubmissionConfirmationController),
                                          Navigation::NavigationStep.new(StateFile::Questions::ReturnStatusController),
                                        ], false),
    ].freeze

    def self.controllers
      sections.flat_map(&:controllers)
    end

    def self.pages(visitor_record)
      sections.flat_map { |section| section.pages(visitor_record) }
    end
  end
end
