module TaxReturnStatusHelper
  def grouped_status_options_for_select
    TaxReturnStatus::STATUSES_BY_STAGE.to_a.map do |stage, statuses|
      translated_stage = TaxReturnStatusHelper.stage_translation(stage)
      translated_statuses = statuses.map { |status| [TaxReturnStatusHelper.status_translation(status), status.to_s] }
      [translated_stage, translated_statuses]
    end
  end

  def stage_and_status_translation(status)
    TaxReturnStatusHelper.stage_and_status_translation(status)
  end

  def stage_translation(stage)
    TaxReturnStatusHelper.stage_translation(stage)
  end

  def status_translation(status)
    TaxReturnStatusHelper.status_translation(status)
  end

  def stage_translation_from_status(status)
    TaxReturnStatusHelper.stage_translation_from_status(status)
  end

  def self.stage_and_status_translation(status)
    "#{stage_translation_from_status(status)}/#{status_translation(status)}"
  end

  def language_options
    all_interview_languages = I18n.backend.translations.dig(I18n.locale, :general, :language_options)
    all_interview_languages.select { |key, _| I18n.locale_available?(key) }.invert # only show available locales
  end

  private

  def certification_label(tax_return)
    text = ""
    if tax_return.certification_level.blank?
      text << "N/A"
      color = "unassigned"
    end
    if tax_return.certification_level == "advanced"
      text << "ADV"
      unassigned = "magenta"
    end
    if tax_return.certification_level == "basic"
      text << "BAS"
      unassigned = "teal"
    end
    text << " | HSA" if tax_return.certification_level && tax_return.is_hsa?
    content_tag(:span, text, class: ["label", "label--#{color}", "certification-label"])
  end

  def self.stage_translation_from_status(status)
    stage = status.to_s.split("_")[0]
    stage_translation(stage)
  end

  def self.stage_translation(stage)
    I18n.t("hub.tax_returns.stage." + stage)
  end

  def self.status_translation(status)
    I18n.t("hub.tax_returns.status." + status.to_s)
  end
end
