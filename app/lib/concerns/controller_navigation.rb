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

  def return_to_review?(return_to_review_param, showable_pages)
    return true if return_to_review_param == "y"
    showable_pages.none? do |page_info|
      page_controller_name = page_info[:controller].name.demodulize.underscore
      possible_matches = [page_controller_name, "#{page_controller_name}_#{page_info[:item_index]}", page_info[:step], "#{page_info[:step]}_#{page_info[:item_index]}"]
      possible_matches.include? return_to_review_param
    end
  end

  def next(controller_class = nil)
    all_pages = pages(current_controller.visitor_record)
    current_page_index = index(all_pages, controller_class)
    return unless current_page_index
    pages_until_end = all_pages[current_page_index + 1..-1]
    showable_pages_until_end = select_showable(pages_until_end)

    return_to_review_param = (current_controller.params[:return_to_review_after] ||
      current_controller.params[:return_to_review])
    if return_to_review?(return_to_review_param, showable_pages_until_end)
      { controller: current_controller.review_controller }
    else
      next_page_info = showable_pages_until_end.first
      next_page_info[:params] = { return_to_review: current_controller.params[:return_to_review],
                                  return_to_review_before: current_controller.params[:return_to_review_before],
                                  return_to_review_after: current_controller.params[:return_to_review_after] }.compact
      next_page_info
    end
  end

  def prev
    all_pages = pages(current_controller.visitor_record)
    current_page_index = index(all_pages)
    return unless current_page_index&.nonzero?
    pages_until_beginning = all_pages[0..current_page_index - 1].reverse
    showable_pages_until_beginning = select_showable(pages_until_beginning)

    return_to_review_param = (current_controller.params[:return_to_review_before] ||
      current_controller.params[:return_to_review_after] ||
      current_controller.params[:return_to_review])
    if return_to_review?(return_to_review_param, showable_pages_until_beginning)
      { controller: current_controller.review_controller }
    else
      prev_page_info = showable_pages_until_beginning.first
      prev_page_info[:params] = { return_to_review: current_controller.params[:return_to_review],
                                  return_to_review_before: current_controller.params[:return_to_review_before],
                                  return_to_review_after: current_controller.params[:return_to_review_after] }.compact
      prev_page_info
    end
  end

  private

  def index(list, controller_class = nil)
    controller_class ||= current_controller.class
    index = list.index { |page_info| page_info[:controller] == controller_class && page_info[:item_index] == item_index }
    if index.nil?
      # we might be missing an item_index param - try looking for a page with item_index 0
      # rubocop:disable Style/NumericPredicate
      index = list.index { |page_info| page_info[:controller] == controller_class && page_info[:item_index] == 0 }
      # rubocop:enable Style/NumericPredicate
    end
    index
  end

  def select_showable(pages)
    pages.select do |page_info|
      controller_class = page_info[:controller]
      # We should not be using arity to decide how to call `show?`
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
