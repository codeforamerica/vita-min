class StateFile::FaqController < ApplicationController
  layout "state_file"

  def index
    intake_start = Rails.configuration.state_file_start_of_open_intake
    active_tax_year = if (app_time.year == intake_start.year) && app_time < intake_start
                        # if the start of intake is set to this year and it is currently before that date, we should still show the previous year's states
                        Rails.configuration.statefile_current_tax_year - 1
                      else
                        Rails.configuration.statefile_current_tax_year
                      end
    visible_state_code_names = StateFile::StateInformationService.state_code_to_name_map.filter { |code, name| StateFile::StateInformationService.filing_years(code).include?(active_tax_year) }
    @state_code_names = if params[:us_state] == 'us'
                          visible_state_code_names
                        else
                          visible_state_code_names.slice(params[:us_state])
                        end
  end

  def show
    @section_key = params[:section_key]
    @faq_category = FaqCategory.find_by(slug: @section_key, product_type: FaqCategory.state_to_product_type(params[:us_state]))

    raise ActionController::RoutingError.new('Not found') unless @faq_category
  end
end
