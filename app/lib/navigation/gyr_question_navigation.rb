module Navigation
  class GyrQuestionNavigation
    include ControllerNavigation

    FLOW = [
      Questions::WelcomeController, # deprecated. exists only for redirect. will be removed in future
      Questions::TriagePersonalInfoController, # creates Intake record and Client record
      Questions::TriageIncomeLevelController,
      Questions::TriageGyrController,
      Questions::TriageDiyController,
      Questions::TriageDoNotQualifyController,
      Questions::TriageGyrDiyController,
      Questions::TriageGyrIdsController,

      ## Main flow
      Questions::EnvironmentWarningController,

      # Contact information and preferences
      Questions::PersonalInfoController, # creates Intake record and Client record, if triage was skipped
      Questions::AtCapacityController, # possible off-boarding when at capacity
      Questions::SsnItinController,
      Questions::BacktaxesController,
      Questions::StartWithCurrentYearController,
      Questions::ReturningClientController, # possible off-boarding from flow
      Questions::InterviewSchedulingController,
      Questions::NotificationPreferenceController,
      Questions::PhoneNumberCanReceiveTextsController,
      Questions::CellPhoneNumberController,
      Questions::PhoneVerificationController,
      Questions::EmailAddressController,
      Questions::EmailVerificationController,
      Questions::ReturningClientController,

      # Consent
      Questions::ConsentController, # Authenticates the client
                                    # Advances statuses to "In Progress"
                                    # generate a 14446 signed by the primary
                                    # generate a "Preliminary" 13614-C signed by the primary
                                    # Routes client to a vita partner, if route-able
                                    # creates TaxReturn records for backtaxes years
      Questions::OptionalConsentController, # generate a "Preliminary" 13614-C with signed f15080 (vita disclosure pdf)
      Questions::ChatWithUsController, # This and all later controllers require a client to be signed in.,
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

      Questions::DependentsController,

      # Dependent related questions
      Questions::DependentCareController,

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
      Questions::BalancePaymentController,
      Questions::BankDetailsController,
      Questions::MailingAddressController,
      # After this links to document flow --> See Navigation::DocumentNavigation

      Questions::FinalInfoController, # generate and replace the "Preliminary" 13614-C with "Original 13614-C.pdf"
      Questions::SuccessfullySubmittedController,

      # Optional Demographic Questions
      Questions::DemographicQuestionsController,
      Questions::DemographicEnglishConversationController,
      Questions::DemographicEnglishReadingController,
      Questions::DemographicDisabilityController,
      Questions::DemographicVeteranController,
      Questions::DemographicPrimaryRaceController,
      Questions::DemographicSpouseRaceController,
    ].freeze
  end
end
