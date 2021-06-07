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
    Documents::EmploymentController,
    Documents::Form1099rsController,
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
