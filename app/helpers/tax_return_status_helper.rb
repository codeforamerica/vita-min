module TaxReturnStatusHelper


  def grouped_tax_return_status_options
    options = []
    TaxReturn::STAGES.map do |stage|
      statuses = TaxReturn.statuses_for(stage)
      select = [translated_stage(stage), status_options = []]
      statuses.map do |status, _|
        status_options.push([translated_status(status), status])
      end
      options << select
    end
    options
  end

  def translated_status(status)
    return "" unless status
    I18n.t("case_management.tax_returns.status." + status)
  end

  def translated_stage(stage)
    return "" unless stage
    I18n.t("case_management.tax_returns.stage." + stage)
  end

  def status_with_stage(tax_return)
    return "N/A" unless tax_return.status
    "#{translated_stage(tax_return.stage)} / #{translated_status(tax_return.status)}"
  end
end