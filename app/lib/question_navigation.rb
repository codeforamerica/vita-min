class QuestionNavigation
  include ControllerNavigation

  FLOW = [
    # Triage
    Questions::WelcomeController,
    Questions::FileWithHelpController,
    Questions::EipOnlyController,
    # FilingMightHelpController redirects to BackTaxesController to start a full intake from stimulus triage
    Questions::BacktaxesController, # create Intake record
    Questions::EnvironmentWarningController,
    Questions::StartWithCurrentYearController,

    # VITA eligibility checks
    Questions::EligibilityController,

    # Overview
    Questions::OverviewController,

    # Contact information
    Questions::PersonalInfoController,
    Questions::AtCapacityController,
    Questions::ChatWithUsController,
    Questions::PhoneNumberController,
    Questions::EmailAddressController,
    Questions::ReturningClientController, # possible off-boarding from flow
    Questions::NotificationPreferenceController,

    # Consent
    Questions::ConsentController, # Advances statuses to "In Progress"
                                  # generate a 14446 signed by the primary
                                  # generate a "Preliminary" 13614-C signed by the primary
    Questions::OptionalConsentController,

    # Primary filer personal information
    Questions::LifeSituationsController,
    Questions::IssuedIdentityPinController,

    # Marital Status
    Questions::EverMarriedController,
    Questions::MarriedController,
    Questions::LivedWithSpouseController,
    Questions::SeparatedController,
    Questions::SeparatedYearController,
    Questions::DivorcedController,
    Questions::DivorcedYearController,
    Questions::WidowedController,
    Questions::WidowedYearController,

    # Filing status
    Questions::FilingJointController,

    # Alimony
    Questions::ReceivedAlimonyController,
    Questions::PaidAlimonyController,

    # Spouse email
    Questions::SpouseEmailAddressController,

    # Spouse consent
    Questions::SpouseConsentController, # generate and replace the 14446 signed by the primary
                                        # generate and replace "Preliminary" 13614-C signed by the primary and spouse

    # Spouse personal information
    Questions::SpouseLifeSituationsController,
    Questions::SpouseIssuedIdentityPinController,

    # Dependents
    Questions::HadDependentsController,

    # Dependent related questions
    Questions::DependentCareController,
    Questions::AdoptedChildController,

    # Student questions
    Questions::StudentController,
    Questions::StudentLoanInterestController,

    # Income from working
    Questions::JobCountController,
    Questions::OtherStatesController,

    # Work Situations
    Questions::WorkSituationsController,

    # Income from benefits
    Questions::DisabilityIncomeController,

    # Investment interest
    Questions::InterestIncomeController,

    # Investment sale income or loss
    Questions::SoldAssetsController,
    Questions::AssetSaleIncomeController,
    Questions::AssetSaleLossController,

    # Retirement income/contributions
    Questions::SocialSecurityOrRetirementController,
    Questions::SocialSecurityIncomeController,
    Questions::RetirementIncomeController,
    Questions::RetirementContributionsController,

    # Other income
    Questions::OtherIncomeController,
    Questions::OtherIncomeTypesController,

    # Health insurance
    Questions::HealthInsuranceController,
    Questions::HsaController,

    # Itemizing
    Questions::MedicalExpensesController,
    Questions::CharitableContributionsController,
    Questions::GamblingIncomeController,
    Questions::SchoolSuppliesController,
    Questions::LocalTaxController,
    Questions::LocalTaxRefundController,

    # Related to home ownership
    Questions::SoldHomeController,
    Questions::MortgageInterestController,
    Questions::HomebuyerCreditController,

    # Miscellaneous
    Questions::DisasterLossController,
    Questions::DebtForgivenController,
    Questions::IrsLetterController,
    Questions::TaxCreditDisallowedController,
    Questions::EstimatedTaxPaymentsController,
    Questions::SelfEmploymentLossController,
    Questions::EnergyEfficientPurchasesController,

    # Additional Information
    Questions::AdditionalInfoController, # sets 'completed_yes_no_questions_at'
                                         # generate and replace the "Preliminary" 13614-C signed by the primary and spouse with yes/no questions filled out

    # Documents --> See DocumentNavigation
    Questions::OverviewDocumentsController,

    # Interview time preferences
    Questions::InterviewSchedulingController,

    # Payment info
    Questions::RefundPaymentController,
    Questions::SavingsOptionsController,
    Questions::BalancePaymentController,
    Questions::BankDetailsController,
    Questions::MailingAddressController,

    # Optional Demographic Questions
    Questions::DemographicQuestionsController,
    Questions::DemographicEnglishConversationController,
    Questions::DemographicEnglishReadingController,
    Questions::DemographicDisabilityController,
    Questions::DemographicVeteranController,
    Questions::DemographicPrimaryRaceController,
    Questions::DemographicSpouseRaceController,
    Questions::DemographicPrimaryEthnicityController,
    Questions::DemographicSpouseEthnicityController,

    # Additional Information
    Questions::FinalInfoController, # sets 'completed_intake_at' & creates Original 13614-C
                                    # replace "Preliminary" with "Original" 13614-C completely filled out
    Questions::SuccessfullySubmittedController,
    Questions::FeedbackController,
  ].freeze
end
