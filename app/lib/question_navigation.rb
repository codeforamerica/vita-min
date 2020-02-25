class QuestionNavigation
  FLOW = [
    # Eligibility
    Questions::EligibilityController,

    # Personal Information
    Questions::IdentityController,
    Questions::ConsentController,
    Questions::WelcomeController,
    Questions::MailingAddressController,
    Questions::NotificationPreferenceController, # creates initial Zendesk ticket
    Questions::WasStudentController,
    Questions::OnVisaController,
    Questions::HadDisabilityController,
    Questions::WasBlindController,
    Questions::IssuedIdentityPinController,
    Questions::RefundPaymentController,
    Questions::SavingsOptionsController,
    Questions::BalancePaymentController,
    Questions::OtherStatesController,

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
    Questions::FilingJointController,

    # Spouse authentication
    Questions::SpouseIdentityController,
    Questions::WelcomeSpouseController,

    # Spouse personal information
    Questions::SpouseWasStudentController,
    Questions::SpouseOnVisaController,
    Questions::SpouseHadDisabilityController,
    Questions::SpouseWasBlindController,
    Questions::SpouseIssuedIdentityPinController,

    # Dependents
    Questions::HadDependentsController,

    # Income
    Questions::JobCountController,
    Questions::WagesController,
    Questions::TipsController,
    Questions::SelfEmploymentController,
    Questions::SelfEmploymentLossController,
    Questions::RetirementIncomeController,
    Questions::SocialSecurityIncomeController,
    Questions::UnemploymentIncomeController,
    Questions::DisabilityIncomeController,
    Questions::InterestIncomeController,
    Questions::AssetSaleIncomeController,
    Questions::AssetSaleLossController,
    Questions::ReceivedAlimonyController,
    Questions::RentalIncomeController,
    Questions::FarmIncomeController,
    Questions::GamblingIncomeController,
    Questions::LocalTaxRefundController,
    Questions::OtherIncomeController,
    Questions::OtherIncomeTypesController,

    # Expenses
    Questions::MortgageInterestController,
    Questions::LocalTaxController,
    Questions::MedicalExpensesController,
    Questions::CharitableContributionsController,
    Questions::StudentLoanInterestController,
    Questions::DependentCareController,
    Questions::RetirementContributionsController,
    Questions::SchoolSuppliesController,
    Questions::PaidAlimonyController,
    Questions::StudentController,
    Questions::SoldHomeController,
    Questions::HsaController,
    Questions::HealthInsuranceController,

    # Life Events
    Questions::HomebuyerCreditController,
    Questions::EnergyEfficientPurchasesController,
    Questions::DebtForgivenController,
    Questions::DisasterLossController,
    Questions::AdoptedChildController,
    Questions::TaxCreditDisallowedController,
    Questions::IrsLetterController,
    Questions::EstimatedTaxPaymentsController,

    # Additional Questions
    Questions::AdditionalInfoController, # appends 13614-C to Zendesk ticket

    # Documents --> See DocumentNavigation

    Questions::InterviewSchedulingController,

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

    Questions::FinalInfoController,
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
