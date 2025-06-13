module Navigation
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
      Documents::AdditionalDocumentsController,
      Documents::OverviewController,
    ].freeze

    CONTROLLER_BY_DOCUMENT_TYPE = FLOW.each_with_object({}) do |klass, mapping|
      mapping[klass.document_type_key] ||= klass if klass.document_type_key
    end

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
      return { controller: Documents::IdGuidanceController } if index(pages).zero?

      super
    end
  end
end
