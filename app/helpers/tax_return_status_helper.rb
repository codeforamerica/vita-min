module TaxReturnStatusHelper
  def grouped_status_options_for_select
    TaxReturnStateMachine.available_states_for(role_type: current_user.role_type).map do |stage, statuses|
      translated_stage = TaxReturnStatusHelper.stage_translation(stage)
      translated_statuses = statuses.map { |status| [TaxReturnStatusHelper.status_translation(status), status.to_s] }
      [translated_stage, translated_statuses]
    end
  end

  def grouped_status_options_for_partner
    if current_user.role_type == GreeterRole::TYPE
      [
        [stage_translation("intake"), [
          [status_translation("intake_needs_doc_help"), "intake_needs_doc_help"],
          [status_translation("intake_greeter_info_requested"), "intake_greeter_info_requested"],
          [status_translation("intake_ready"), "intake_ready"],
        ]],
        [stage_translation("file"), [
          [status_translation("file_not_filing"), "file_not_filing"],
          [status_translation("file_hold"), "file_hold"]
        ]]
      ]
    else
      [
        [stage_translation("intake"), [
          [status_translation("intake_needs_doc_help"), "intake_needs_doc_help"],
          [status_translation("intake_info_requested"), "intake_info_requested"],
          [status_translation("intake_greeter_info_requested"), "intake_greeter_info_requested"],
          [status_translation("intake_ready"), "intake_ready"],
          [status_translation("intake_reviewing"), "intake_reviewing"],
          [status_translation("intake_ready_for_call"), "intake_ready_for_call"]
        ]],
        [stage_translation("prep"), [
          [status_translation("prep_ready_for_prep"), "prep_ready_for_prep"],
          [status_translation("prep_preparing"), "prep_preparing"],
          [status_translation("prep_info_requested"), "prep_info_requested"]
        ]],
        [stage_translation("review"), [
          [status_translation("review_ready_for_qr"), "review_ready_for_qr"],
          [status_translation("review_reviewing"), "review_reviewing"],
          [status_translation("review_ready_for_call"), "review_ready_for_call"],
          [status_translation("review_signature_requested"), "review_signature_requested"],
          [status_translation("review_info_requested"), "review_info_requested"]
        ]],
        [stage_translation("file"), [
          [status_translation("file_needs_review"), "file_needs_review"],
          [status_translation("file_ready_to_file"), "file_ready_to_file"],
          [status_translation("file_efiled"), "file_efiled"],
          [status_translation("file_mailed"), "file_mailed"],
          [status_translation("file_rejected"), "file_rejected"],
          [status_translation("file_accepted"), "file_accepted"],
          [status_translation("file_not_filing"), "file_not_filing"],
          [status_translation("file_hold"), "file_hold"],
          [status_translation("file_fraud_hold"), "file_fraud_hold"]
        ]]
      ]
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
    return unless status
    
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
    return unless status

    stage = status.to_s.split("_")[0]
    stage_translation(stage)
  end

  def self.stage_translation(stage)
    return unless stage

    I18n.t("hub.tax_returns.stage." + stage)
  end

  def self.status_translation(status)
    return unless status

    I18n.t("hub.tax_returns.status." + status.to_s)
  end
end
