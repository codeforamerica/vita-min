class QuestionNavigation
  FLOW = [
    # Feelings
    Questions::FeelingsController,
    Questions::BacktaxesController,
    Questions::StartWithCurrentYearController,
    Questions::ChatWithUsController,

    # VITA eligibility checks
    Questions::EligibilityController,

    # Overview
    Questions::OverviewController,
    Questions::OverviewDocumentsController,

    # Contact information
    Questions::PersonalInfoController,
    Questions::PhoneNumberController,
    Questions::EmailAddressController,

    # Authentication
    Questions::IdentityController,

    # Consent
    Questions::ConsentController,

    # Contact information
    Questions::MailingAddressController,
    Questions::NotificationPreferenceController, # creates initial Zendesk ticket

    # Primary filer personal information
    Questions::WasStudentController,
    Questions::OnVisaController,
    Questions::HadDisabilityController,
    Questions::WasBlindController,
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

    # Spouse authentication
    Questions::SpouseIdentityController,

    # Spouse personal information
    Questions::SpouseConsentController,
    Questions::SpouseWasStudentController,
    Questions::SpouseOnVisaController,
    Questions::SpouseHadDisabilityController,
    Questions::SpouseWasBlindController,
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
    Questions::WagesController,
    Questions::SelfEmploymentController,
    Questions::TipsController,

    # Income from benefits
    Questions::UnemploymentIncomeController,
    Questions::DisabilityIncomeController,

    # Investment income/loss
    Questions::InterestIncomeController,
    Questions::AssetSaleIncomeController,
    Questions::AssetSaleLossController,

    # Retirement income/contributions
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
    Questions::AdditionalInfoController, # appends 13614-C to Zendesk ticket

    # Documents --> See DocumentNavigation

    # Interview time preferences
    Questions::InterviewSchedulingController,

    # Payment info
    Questions::RefundPaymentController,
    Questions::SavingsOptionsController,
    Questions::BalancePaymentController,

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
    Questions::FinalInfoController, # appends final 13614-C, consent, & docs to Zendesk
    Questions::SuccessfullySubmittedController,
  ].freeze

  class << self
    delegate :first, to: :controllers

    def controllers
      FLOW
    end
  end

  delegate :controllers, to: :class

  def initialize(current_controller)
    @current_controller = current_controller
  end

  def next
    return unless index

    controllers_until_end = controllers[index + 1..-1]
    seek(controllers_until_end)
  end

  private

  def index
    controllers.index(@current_controller.class)
  end

  def seek(list)
    list.detect do |controller_class|
      controller_class.show?(@current_controller.current_intake)
    end
  end
end
