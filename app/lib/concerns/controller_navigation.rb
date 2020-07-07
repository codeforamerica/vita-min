module ControllerNavigation
  extend ActiveSupport::Concern

  included do
    class << self
      delegate :first, to: :controllers

      def controllers
        const_get("FLOW")
      end
    end

    delegate :controllers, to: :class
  end

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
      controller_class.show?(@current_controller.visitor_record)
    end
  end

end
