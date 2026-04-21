class FaqController < ApplicationController
  skip_before_action :check_maintenance_mode

  ALLOWED_SORT_COLUMNS = %w[position updated_at created_at].freeze

  def index
    @search = params[:search] || ""
    @faq_categories = FaqCategory.where(product_type: :gyr)
    @faq_items = faq_items.joins(:faq_category).where(faq_categories: { product_type: :gyr})
    @faq_items = apply_sort(@faq_items)
  end

  def section_index
    # validate that it is actually good, 404 if not

    @section_key = params[:section_key]
    @search = params[:search] || ""
    @faq_category = FaqCategory.find_by(slug: @section_key)
    raise ActionController::RoutingError.new('Not found') unless @faq_category
    @faq_items = faq_items.where(faq_category_id: @faq_category.id)
  end

  def show
    @section_key = params[:section_key]
    @question_key = params[:question_key].underscore
    @faq_item = FaqCategory.find_by(slug: @section_key)&.faq_items&.find_by(slug: @question_key)
    raise ActionController::RoutingError.new('Not found') unless @faq_item

    @survey = FaqSurvey.find_or_initialize_by(visitor_id: visitor_id, question_key: @question_key)

    if params[:diy_chat_with_us_token].present?
      DiyIntake.find_by(token: params[:diy_chat_with_us_token], clicked_chat_with_us_at: nil)&.touch(:clicked_chat_with_us_at)
    end
  end

  def answer_survey
    @question_key = params[:question_key].underscore
    @survey = FaqSurvey.find_or_initialize_by(visitor_id: visitor_id, question_key: @question_key)

    @survey.update(params.require(:faq_survey).permit(:answer))
    redirect_to faq_question_path(section_key: params[:section_key], question_key: @question_key)
  end

  private

  def include_analytics?
    true
  end

  def faq_items
    search_locale = locale&.to_sym
    if @search.present? && I18n.available_locales.include?(search_locale)
      return FaqItem.send(:"search_#{search_locale}", @search)
    end
    FaqItem.all
  end

  # Allows clients to sort the FAQ list via a `sort` query param, e.g. `?sort=position asc`.
  # Only known columns are permitted and the string is cleaned of anything but word chars,
  # commas, dots, and whitespace before being handed to AR for ordering.
  def apply_sort(scope)
    return scope if params[:sort].blank?

    cleaned = params[:sort].to_s.gsub(/[^a-zA-Z0-9_,\.\s]/, "").strip
    return scope if cleaned.empty?

    mentioned_column = ALLOWED_SORT_COLUMNS.find { |c| cleaned.include?(c) }
    return scope unless mentioned_column

    scope.reorder(Arel.sql(cleaned))
  end
end
