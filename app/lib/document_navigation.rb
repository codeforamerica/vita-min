# frozen_string_literal: true

class DocumentNavigation
  FLOW = [
    Documents::IdGuidanceController,
    Documents::IdsController,
    Documents::SelfieInstructionsController,
    Documents::SelfiesController,
    Documents::SsnItinsController,
    Documents::IntroController,
    Documents::W2sController,
    Documents::Form1095asController,
    Documents::Form1098sController,
    Documents::Form1098esController,
    Documents::Form1098tsController,
    Documents::Form1099asController,
    Documents::Form1099bsController,
    Documents::Form1099csController,
    Documents::Form1099divsController,
    Documents::Form1099intsController,
    Documents::Form1099ksController,
    Documents::Form1099miscsController,
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
    Documents::AdditionalDocumentsController,
    Documents::RequestedDocumentsLaterController,
    Documents::OverviewController,
    Documents::SendRequestedDocumentsLaterController,
  ].freeze

  REQUIRED_DOCUMENT_TYPES = [
    Documents::IdsController,
    Documents::SelfiesController,
    Documents::SsnItinsController,
    Documents::RequestedDocumentsLaterController,
  ].map(&:document_type)
  DOCUMENT_TYPES = FLOW.map(&:document_type).compact
  CONTROLLER_BY_DOCUMENT_TYPE = FLOW
    .find_all(&:document_type)
    .index_by(&:document_type)

  class << self
    delegate :first, to: :controllers

    def controllers
      FLOW
    end

    def first_for_intake(intake)
      controllers.find { |c| c.show?(intake) }
    end

    def document_types_for_intake(intake)
      controllers
        .find_all { |c| c.show?(intake) }
        .map(&:document_type)
        .compact
    end

    def document_controller_for_type(document_type)
      CONTROLLER_BY_DOCUMENT_TYPE[document_type]
    end
  end

  delegate :controllers, to: :class

  def initialize(current_controller)
    @current_controller = current_controller
  end

  def next_for_intake(intake)
    current_index = controllers.index(@current_controller.class)
    return if current_index.nil?

    controllers[(current_index + 1)..-1].find { |c| c.show?(intake) }
  end
end
