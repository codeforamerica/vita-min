class StateFile::FaqController < ApplicationController
  layout "state_file"

  def index
    @az_faq_categories = FaqCategory.where(product_type: :az)
    @ny_faq_categories = FaqCategory.where(product_type: :ny)
  end

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
end
