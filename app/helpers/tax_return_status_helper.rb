module TaxReturnStatusHelper
  def grouped_status_options_for_select
    TaxReturn.grouped_statuses.to_a.map do |stage, statuses|
      translated_stage = TaxReturnStatusHelper.stage_translation(stage)
      translated_statuses = statuses.map { |status| [TaxReturnStatusHelper.status_translation(status), status.to_s] }
      [translated_stage, translated_statuses]
    end
  end

  def stage_and_status_translation(status)
    TaxReturnStatusHelper.stage_and_status_translation(status)
  end

  def status_translation(status)
    TaxReturnStatusHelper.status_translation(status)
  end

  def self.stage_and_status_translation(status)
    stage = status.to_s.split("_")[0]
    "#{stage_translation(stage)}/#{status_translation(status)}"
  end

  private

  def self.stage_translation(stage)
    I18n.t("case_management.tax_returns.stage." + stage)
  end

  def self.status_translation(status)
    I18n.t("case_management.tax_returns.status." + status.to_s)
  end
end
