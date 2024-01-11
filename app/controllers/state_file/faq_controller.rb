class StateFile::FaqController < ApplicationController
  layout "state_file"

  def index; end

  def show
    @section_key = params[:section_key]
    @faq_category = FaqCategory.find_by(slug: @section_key, product_type: FaqCategory.state_to_product_type(params[:us_state]))

    raise ActionController::RoutingError.new('Not found') unless @faq_category
  end
end
