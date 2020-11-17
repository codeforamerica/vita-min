module TaxReturnStatusHelper
  def grouped_status_options
    TaxReturnStatusHelper.grouped_status_options
  end

  def stage_and_status_translation(status)
    TaxReturnStatusHelper.stage_and_status_translation(status)
  end

  def self.grouped_status_options
    stages = {}
    printable_statuses = TaxReturn::STATUSES.except(:intake_before_consent).keys.map(&:to_s)
    printable_statuses.map do |status|
      stage = status.split("_")[0]
      translated_stage = stage_translation(stage)
      stages[translated_stage] = [] unless stages.key?(translated_stage)
      stages[translated_stage].push([status_translation(status), status])
    end
    stages.to_a
  end

  def self.stage_and_status_translation(status)
    stage = status.split("_")[0]
    return "#{stage_translation(stage)}/#{status_translation(status)}"
  end

  private

  def self.stage_translation(stage)
    I18n.t("case_management.tax_returns.stage." + stage)
  end

  def self.status_translation(status)
    I18n.t("case_management.tax_returns.status." + status.to_s)
  end
end
