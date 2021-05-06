# frozen_string_literal: true

class DocumentNavigation
  include ControllerNavigation

  FLOW = [
    Documents::IdGuidanceController,
    Documents::IdsController,
    Documents::SelfieInstructionsController,
    Documents::SelfiesController,
    Documents::SsnItinsController,
    Documents::IntroController,
    Documents::Form1095asController,
    Documents::Form1098sController,
    Documents::Form1098esController,
    Documents::Form1098tsController,
    Documents::Form1099asController,
    Documents::Form1099bsController,
    Documents::Form1099csController,
    Documents::Form1099divsController,
    Documents::Form1099intsController,
    Documents::EmploymentController,
    Documents::Form1099rsController,
    Documents::Form1099ssController,
    Documents::Form1099sasController,
    Documents::Form1099gsController,
    Documents::Form5498sasController,
    Documents::IraStatementsController,
    Documents::PropertyTaxStatementsController,
    Documents::Rrb1099sController,
    Documents::Ssa1099sController,
    Documents::StudentAccountStatementsController,
    Documents::CareProviderStatementsController,
    Documents::W2gsController,
    Documents::PriorTaxReturnsController,
    Documents::AdditionalDocumentsController, # Advances statuses to Ready
    Documents::OverviewController,
  ].freeze


  CONTROLLER_BY_DOCUMENT_TYPE = FLOW
    .find_all(&:document_type_key)
    .index_by(&:document_type_key)

  class << self
    def first_for_intake(intake)
      controllers.find { |c| c.show?(intake) }
    end

    def document_controller_for_type(document_type)
      CONTROLLER_BY_DOCUMENT_TYPE[document_type]
    end
  end

  delegate :controllers, to: :class

  def prev
    return Questions::OverviewDocumentsController if index.zero?

    super
  end
end
