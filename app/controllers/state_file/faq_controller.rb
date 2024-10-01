class StateFile::FaqController < ApplicationController
  layout "state_file"

  def index
    intake_start = Rails.configuration.state_file_start_of_open_intake
    intake_end = Rails.configuration.state_file_end_of_in_progress_intakes
    tax_year = Rails.configuration.statefile_current_tax_year

    filter_years = if intake_start < app_time && app_time < intake_end # intake is open
                     # show currently open states
                     [tax_year]
                   elsif app_time.year == intake_start.year && app_time < intake_start # before intake opens this year
                     # show states that were open the previous year and will open this year
                     [tax_year - 1, tax_year]
                   else # intake is closed for the year
                     # show states that were open this year and will open next year
                     [tax_year, tax_year + 1]
                   end

    visible_state_code_names = StateFile::StateInformationService.state_code_to_name_map.filter do |state_code, _|
      filter_years.all? { |year| StateFile::StateInformationService.filing_years(state_code).include?(year) }
    end
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
