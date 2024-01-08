class StateFile::FaqController < ApplicationController
  layout "state_file"

  def index; end

  def section_index
    # validate that it is actually good, 404 if not

    @section_key = params[:section_key]
    @faq_category = FaqCategory.find_by(slug: @section_key)

    raise ActionController::RoutingError.new('Not found') unless @faq_category
  end

  def show
    @section_key = params[:section_key]
    @question_key = params[:question_key].underscore
    @faq_item = FaqCategory.find_by(slug: @section_key)&.faq_items&.find_by(slug: @question_key)
    raise ActionController::RoutingError.new('Not found') unless @faq_item
  end
end
