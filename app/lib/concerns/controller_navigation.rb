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

  def return_to_review?(return_to_review_param)
    if current_controller.respond_to? :return_to_review_param
      controller_class_name = current_controller.class.name.demodulize.underscore
      positive_cases = ["y", controller_class_name, "#{controller_class_name}_#{item_index}"]
      positive_cases.include? current_controller.return_to_review_param
    else
      false
    end
  end

  def next(controller_class = nil)
    all_pages = pages(current_controller.visitor_record)
    shown_pages =

    return { controller: current_controller.review_controller } if return_to_review?(current_controller.return_to_review_after)

    current_page_index = index(all_pages, controller_class)
    return unless current_page_index

    controllers_until_end = all_pages[current_page_index + 1..-1]
    seek(controllers_until_end)
  end

  def prev
    return { controller: current_controller.review_controller } if return_to_review?(current_controller.return_to_review_before)

    all_pages = pages(current_controller.visitor_record)
    current_page_index = index(all_pages)
    return unless current_page_index&.nonzero?

    controllers_to_beginning = all_pages[0..current_page_index - 1].reverse
    seek(controllers_to_beginning)
  end

  private

  def index(list, controller_class = nil)
    controller_class ||= current_controller.class
    index = list.index { |page_info| page_info[:controller] == controller_class && page_info[:item_index] == item_index }
    if index.nil?
      # we might be missing an item_index param - try looking for a page with item_index 0
      # rubocop:disable Style/NumericPredicate
      index = list.index { |page_info| page_info[:controller] == controller_class && page_info[ :item_index] == 0 }
      # rubocop:enable Style/NumericPredicate
    end
    index
  end

  def pages_to_show(list)
    list.select do |page_info|
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
      else
        false
      end
    end
  end
end
