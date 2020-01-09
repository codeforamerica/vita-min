class QuestionNavigation
  FLOW = [
    # Income
    Questions::WagesController,
    Questions::JobCountController,
    Questions::TipsController,
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
    Questions::SelfEmploymentController,
    Questions::SelfEmploymentLossController,
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
    Questions::DebtForgivenController,
    Questions::DisasterLossController,
    Questions::AdoptedChildController,
    Questions::TaxCreditDisallowedController,
    Questions::IrsLetterController,
    Questions::EstimatedTaxPaymentsController,

    # Additional Questions
    Questions::AdditionalInfoController,

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