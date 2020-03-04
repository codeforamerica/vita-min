# frozen_string_literal: true

class DocumentNavigation
  DOCUMENT_CONTROLLERS = {
    "W-2" => Documents::W2sController,
    "1095-A" => Documents::Form1095asController,
    "1098" => Documents::Form1098sController,
    "1098-E" => Documents::Form1098esController,
    "1098-T" => Documents::Form1098tsController,
    "1099-A" => Documents::Form1099asController,
    "1099-B" => Documents::Form1099bsController,
    "1099-C" => Documents::Form1099csController,
    "1099-DIV" => Documents::Form1099divsController,
    "1099-INT" => Documents::Form1099intsController,
    "1099-K" => Documents::Form1099ksController,
    "1099-MISC" => Documents::Form1099miscsController,
    "1099-R" => Documents::Form1099rsController,
    "1099-S" => Documents::Form1099ssController,
    "1099-SA" => Documents::Form1099sasController,
    "1099-G" => Documents::Form1099gsController,
    "5498-SA" => Documents::Form5498sasController,
    "IRA Statement" => Documents::IraStatementsController,
    "RRB-1099" => Documents::Rrb1099sController,
    "SSN or ITIN" => Documents::SsnItinsController,
    "SSA-1099" => Documents::Ssa1099sController,
    "Student Account Statement" => Documents::StudentAccountStatementsController,
    "Childcare Statement" => Documents::ChildcareStatementsController,
    "W-2G" => Documents::W2gsController,
    "2018 Tax Return" => Documents::PriorTaxReturnsController,
    "Other" => Documents::AdditionalDocumentsController,
  }.freeze
  BEFORE_CONTROLLERS = [
      Documents::IntroController
  ].freeze
  AFTER_CONTROLLERS = [
    Documents::OverviewController
  ].freeze
  DOCUMENT_TYPES = DOCUMENT_CONTROLLERS.keys.freeze

  class << self
    delegate :first, to: :controllers

    def controllers
      DOCUMENT_CONTROLLERS.values
    end

    def all_controllers
      BEFORE_CONTROLLERS + controllers + AFTER_CONTROLLERS
    end

    def document_type(controller_class)
      DOCUMENT_CONTROLLERS.key(controller_class)
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
