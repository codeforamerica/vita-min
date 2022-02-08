module TaxReturnStatusHelper
  def grouped_status_options_for_select
    TaxReturnStateMachine.available_states_for(role_type: current_user.role_type).map do |stage, statuses|
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

  def language_options(only_locales: true)
    all_interview_languages = I18n.backend.translations.dig(I18n.locale, :general, :language_options)
    if only_locales
      return all_interview_languages.select { |key, _| I18n.locale_available?(key) }.invert
    end
    all_interview_languages.invert.sort
  end

  def certification_options_for_select
    TaxReturn.certification_levels.map { |cl| [cl[0].titleize, cl[0]] }
  end

  private

  def certification_label(tax_return)
    classes = %w[label certification-label]
    classes << "label--unassigned" if tax_return.certification_level.blank?
    localization_key = tax_return.certification_level.blank? ? "NA" : "certification_abbrev.#{tax_return.certification_level}"
    tag.span(t("general.#{localization_key}"), class: classes)
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
