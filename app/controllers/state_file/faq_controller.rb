class StateFile::FaqController < ApplicationController
  layout "state_file"

  def index
    @state_code_names = case params[:us_state]
                        when 'us'
                          StateFileBaseIntake::STATE_CODE_AND_NAMES
                        when 'ny'
                          StateFileNyIntake::STATE_CODE_AND_NAME
                        when 'az'
                          StateFileAzIntake::STATE_CODE_AND_NAME
                        end
  end

  def show
    @section_key = params[:section_key]
    @faq_category = FaqCategory.find_by(slug: @section_key, product_type: FaqCategory.state_to_product_type(params[:us_state]))

    raise ActionController::RoutingError.new('Not found') unless @faq_category
  end
end
