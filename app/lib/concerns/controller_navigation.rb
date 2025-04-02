module ControllerNavigation
  extend ActiveSupport::Concern
  attr_reader :current_controller, :item_index
  included do
    class << self
      delegate :first, to: :controllers

      def controllers
        const_get("FLOW")
      end

      def pages(visitor_record = nil)
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
    pages_until_end = all_pages[current_page_index..-1]
    return_to_review_param = (current_controller.params[:return_to_review_after] ||
      current_controller.params[:return_to_review])

    proceed(pages_until_end, return_to_review_param)
  end

  def prev
    all_pages = pages(current_controller.visitor_record)
    current_page_index = index(all_pages)
    return unless current_page_index
    pages_until_beginning = all_pages[0..current_page_index].reverse
    return_to_review_param = (current_controller.params[:return_to_review_before] ||
      current_controller.params[:return_to_review])

    proceed(pages_until_beginning, return_to_review_param)
  end

  private

  def proceed(pages_from_current, return_to_review_param)
    current_page_info = pages_from_current[0]
    remaining_pages = pages_from_current[1..]
    next_showable_page_index = seek(remaining_pages)
    if return_to_review?(return_to_review_param, current_page_info, remaining_pages[next_showable_page_index..])
      { controller: current_controller.review_controller }
    elsif next_showable_page_index.present?
      next_page_info = remaining_pages[next_showable_page_index]
      preserve_return_to_review_params(next_page_info)
      next_page_info
    end
  end

  def preserve_return_to_review_params(page_info)
    return_to_review_params = { return_to_review: current_controller.params[:return_to_review],
                                return_to_review_before: current_controller.params[:return_to_review_before],
                                return_to_review_after: current_controller.params[:return_to_review_after] }.compact
    page_info[:params] = return_to_review_params if return_to_review_params.present?
  end

  def return_to_review?(return_to_review_param, current_page_info, showable_pages)
    return false if return_to_review_param.blank?

    # Case 1: Always return to review if return_to_review=y
    return true if return_to_review_param == "y"

    if showable_pages.present?
      # Case 2: If there are more showable pages, and we don't see a page matching the return to review param, assume
      # that we passed it and return to review
      showable_pages.none? do |page_info|
        ControllerNavigation.page_info_matches_return_to_review_param?(page_info, return_to_review_param)
      end
    else
      # Case 3: If there are no more showable pages, only return to review if the current page matches the return to
      # review param
      ControllerNavigation.page_info_matches_return_to_review_param?(current_page_info, return_to_review_param)
    end
  end

  def self.page_info_matches_return_to_review_param?(page_info, return_to_review_param)
    page_controller_name = page_info[:controller].name.demodulize.underscore
    possible_matches = [page_controller_name,
                        "#{page_controller_name}_#{page_info[:item_index]}",
                        page_info[:step],
                        "#{page_info[:step]}_#{page_info[:item_index]}"]
    possible_matches.include? return_to_review_param
  end

  def index(pages, controller_class = nil)
    controller_class ||= current_controller.class
    index = pages.index { |page_info| page_info[:controller] == controller_class && page_info[:item_index] == item_index }
    if index.nil?
      # if we didn't find a match, try looking for a page with item_index 0
      # rubocop:disable Style/NumericPredicate
      # rubcop is wrong, and `hash[:key] == 0` is not the same as `hash[:key].zero?` (which will raise if key is missing)
      index = pages.index { |page_info| page_info[:controller] == controller_class && page_info[:item_index] == 0 }
      # rubocop:enable Style/NumericPredicate
    end
    index
  end

  def seek(pages)
    pages.index do |page_info|
      controller_class = page_info[:controller]
      # We should not be using arity to decide how to call `show?`
      case controller_class.method(:show?).arity
      when 2
        controller_class.show?(
          controller_class.model_for_show_check(current_controller),
          current_controller
        )
      when -1, 1
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
