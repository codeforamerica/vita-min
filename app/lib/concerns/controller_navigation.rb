module ControllerNavigation
  extend ActiveSupport::Concern
  attr_reader :current_controller
  included do
    class << self
      delegate :first, to: :controllers

      def controllers
        const_get("FLOW")
      end

      def pages(object_for_flow)
        controllers
      end
    end

    delegate :controllers, to: :class
  end

  def initialize(current_controller)
    @current_controller = current_controller
  end

  def next(controller_class = nil)
    return unless index(controller_class)

    controllers_until_end = controllers[index(controller_class) + 1..-1]
    seek(controllers_until_end)
  end

  def prev
    return unless index&.nonzero?

    controllers_to_beginning = controllers[0..index - 1].reverse
    seek(controllers_to_beginning)
  end

  private

  def index(controller_class = nil)
    controller_class ||= current_controller.class
    controllers.index(controller_class)
  end

  def seek(list)
    list.detect do |controller_class|
      if controller_class.method(:show?).arity > 1
        controller_class.show?(
          controller_class.model_for_show_check(current_controller),
          @current_controller
        )
      else
        controller_class.show?(
          controller_class.model_for_show_check(current_controller)
        )
      end
    end
  end
end
