module ControllerNavigation
  extend ActiveSupport::Concern
  attr_reader :current_controller, :item_index
  included do
    class << self
      delegate :first, to: :controllers

      def controllers
        const_get("FLOW")
      end

      def pages(visitor_record)
        controllers.map { |controller| { controller: } }
      end
    end

    delegate :controllers, to: :class
    delegate :pages, to: :class
  end

  def initialize(current_controller, item_index: nil)
    @current_controller = current_controller
    @item_index = item_index
  end

  def next(controller_class = nil)
    all_pages = pages(current_controller.visitor_record)
    current_page_index = index(all_pages, controller_class)
    return unless current_page_index

    controllers_until_end = all_pages[current_page_index + 1..-1]
    seek(controllers_until_end)
  end

  def prev
    all_pages = pages(current_controller.visitor_record)
    current_page_index = index(all_pages)
    return unless current_page_index&.nonzero?

    controllers_to_beginning = all_pages[0..current_page_index - 1].reverse
    seek(controllers_to_beginning)
  end

  private

  def index(list, controller_class = nil)
    controller_class ||= current_controller.class
    list.index { |page_info| page_info[:controller] == controller_class && page_info[:item_index] == item_index}
  end

  def seek(list)
    list.detect do |page_info|
      controller_class = page_info[:controller]
      case controller_class.method(:show?).arity
      when 2
        controller_class.show?(
          controller_class.model_for_show_check(current_controller),
          current_controller
        )
      when 1
        controller_class.show?(
          controller_class.model_for_show_check(current_controller)
        )
      when -2
        # i hate this so much and i want it to die (all the arity checking, not just the negative for optional args)
        controller_class.show?(
          controller_class.model_for_show_check(current_controller),
          item_index: page_info[:item_index]
        )
      end
    end
  end
end
