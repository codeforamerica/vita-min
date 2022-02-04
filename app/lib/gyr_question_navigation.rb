class GyrQuestionNavigation
  include ControllerNavigation

  FLOW = [
      Questions::WelcomeController,
      Questions::TriageIncomeLevelController,
      Questions::TriageStartIdsController,
      Questions::TriageIdTypeController,
      Questions::TriageDocTypeController,
      Questions::TriageBacktaxesYearsController,
      Questions::TriageAssistanceController,
      Questions::TriageIncomeTypesController,
      Questions::TriageGyrController,
      Questions::TriageReferralController,
      Questions::TriageExpressController,
      Questions::TriageGyrExpressController,
      Questions::TriageDoNotQualifyController,

      ## Main flow
      Questions::BacktaxesController, # creates Intake record and Client record
      Questions::EnvironmentWarningController,
      Questions::StartWithCurrentYearController,

      # Overview
      Questions::OverviewController,

      # Contact information and preferences
      Questions::PersonalInfoController,
      Questions::InterviewSchedulingController,
      Questions::NotificationPreferenceController,
      Questions::PhoneNumberCanReceiveTextsController,
      Questions::CellPhoneNumberController,
      Questions::PhoneVerificationController,
      Questions::EmailAddressController,
      Questions::EmailVerificationController,
      Questions::ReturningClientController, # possible off-boarding from flow

      #TODO
      # 1. make sure there are appropriate tests for each controller and form & an overall test for the different paths in the flow

      # Consent
      Questions::ConsentController, # Authenticates the client
                                    # Advances statuses to "In Progress"
                                    # generate a 14446 signed by the primary
                                    # generate a "Preliminary" 13614-C signed by the primary
                                    # Routes client to a vita partner, if routeable
                                    # creates TaxReturn records for backtaxes years
      Questions::OptionalConsentController,
      Questions::AtCapacityController,
      Questions::ChatWithUsController, # This and all later controllers require a client to be signed in.,
      # Primary filer personal information
      Questions::LifeSituationsController,
      Questions::ArpPaymentsController,
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

      # DependentsController (if they had dependents)

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
      Questions::ItemizingController,
      Questions::MedicalExpensesController,
      Questions::CharitableContributionsController,
      Questions::GamblingIncomeController,
      Questions::SchoolSuppliesController,
      Questions::LocalTaxController,
      Questions::LocalTaxRefundController,

      # Related to home ownership
      Questions::EverOwnedHomeController,
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
      Questions::EnergyEfficientPurchasesController, # sets 'completed_yes_no_questions_at'
      # generate and replace the "Preliminary" 13614-C signed by the primary and spouse with yes/no questions filled out

      # Payment info
      Questions::RefundPaymentController,
      Questions::SavingsOptionsController,
      Questions::BalancePaymentController,
      Questions::BankDetailsController,
      Questions::MailingAddressController,

      # Documents --> See DocumentNavigation
      Questions::OverviewDocumentsController,

      Questions::FinalInfoController,
      Questions::SuccessfullySubmittedController,
      Questions::FeedbackController,

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
  ].freeze
end
