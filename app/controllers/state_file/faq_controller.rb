class StateFile::FaqController < ApplicationController
  layout "state_file"

  def index
    visible_state_code_names = StateFile::StateInformationService.state_code_to_name_map
      .filter { |state_code, _| filing_years_to_show.all? { |year| StateFile::StateInformationService.filing_years(state_code).include?(year) } }
      .reduce({}) { |acc, (state_code, state_name)| acc[state_code] = { state_name: }; acc}

    visible_state_code_names.slice!(params[:us_state]) unless params[:us_state] == "us"
    product_types = visible_state_code_names.keys.map do |code|
      FaqCategory.state_to_product_type(code)
    end

    @categories = FaqCategory
      .where(product_type: product_types)
      .reduce(visible_state_code_names) do |acc, cat|
        acc[cat.product_type.last(2)][:categories] ||= []
        acc[cat.product_type.last(2)][:categories] << cat
        acc
      end
  end

  def show
    if params[:us_state] == 'ny'
      redirect_to state_landing_page_path(us_state: "ny")
      return
    end
    @section_key = params[:section_key]
    @faq_category = FaqCategory.find_by(slug: @section_key, product_type: FaqCategory.state_to_product_type(params[:us_state]))

    raise ActionController::RoutingError.new('Not found') unless @faq_category
  end

  private

  def filing_years_to_show
    faq_show_start = Rails.configuration.state_file_show_faq_date_start
    faq_show_end = Rails.configuration.state_file_show_faq_date_end
    tax_year = Rails.configuration.statefile_current_tax_year

    if Rails.env.production?
      if app_time.between?(faq_show_start, faq_show_end) # intake is open
        # show currently open states
        [tax_year]
      elsif app_time.year == faq_show_start.year && app_time < faq_show_start # before intake opens this year
        # show states that were open the previous year and will open this year
        [tax_year - 1, tax_year]
      else # intake is closed for the year
        # show states that were open this year and will open next year
        [tax_year, tax_year + 1]
      end
    else
      if app_time > faq_show_end
        [tax_year + 1]
      else
        [tax_year]
      end
    end
  end
end
