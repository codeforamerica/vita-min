# frozen_string_literal: true

class DocumentNavigation
  DOCUMENT_CONTROLLERS = [
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
    Documents::SsnItinsController,
    Documents::Ssa1099sController,
    Documents::StudentAccountStatementsController,
    Documents::CareProviderStatementsController,
    Documents::W2gsController,
    Documents::PriorTaxReturnsController,
    Documents::AdditionalDocumentsController,
    Documents::RequestedDocumentsController,
    Documents::RequestedDocumentsLaterController,
  ].freeze


  BEFORE_CONTROLLERS = [
    Documents::IntroController
  ].freeze

  AFTER_CONTROLLERS = [
    Documents::OverviewController,
    Documents::SendRequestedDocumentsController,
    Documents::SendRequestedDocumentsLaterController,
  ].freeze

  DOCUMENT_TYPES = DOCUMENT_CONTROLLERS.map { |c| c::DOCUMENT_TYPE }.freeze

  class << self
    delegate :first, to: :controllers

    def controllers
      DOCUMENT_CONTROLLERS
    end

    def all_controllers
      BEFORE_CONTROLLERS + controllers + AFTER_CONTROLLERS
    end

    def document_type(controller_class)
      # was:
      # DOCUMENT_CONTROLLERS.key(controller_class)

      defined?(controller_class::DOCUMENT_TYPE) ? controller_class::DOCUMENT_TYPE : nil
    end

    def controller_for(doc_type)
      controller_type_mapping[doc_type]
    end

    def controller_type_mapping
      @controller_type_mapping_memo ||= Hash[
        # Documents::DocumentUploadQuestionController.descendants
        DOCUMENT_CONTROLLERS
          .filter {|c| c::DOCUMENT_TYPE}         # ignore anything without a document type
          .map { |c| [c::DOCUMENT_TYPE, c]}      # future: append to array
      ].freeze
    end
  end

  delegate :controllers, to: :class
  delegate :all_controllers, to: :class
  delegate :document_type, to: :class

  def initialize(current_controller)
    @current_controller = current_controller
  end

  def next
    return unless index

    controllers_until_end = all_controllers[(index + 1)..-1]
    seek(controllers_until_end)
  end

  def first_for_intake(intake)
    select(intake).first
  end

  def select(intake)
    controllers.select do |controller_class|
      controller_class.show?(intake)
    end
  end

  def types_for_intake(intake)
    select(intake).map do |controller_class|
      document_type(controller_class)
    end
  end

  private

  def index
    all_controllers.index(@current_controller.class)
  end

  def seek(list)
    list.detect do |controller_class|
      controller_class.show?(@current_controller.current_intake)
    end
  end
end
