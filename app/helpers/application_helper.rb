require "ordinalize_full/integer"
module ApplicationHelper
  def number_in_words(number)
    number.ordinalize_in_full
  end

  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge :renderer => VitaMinLinkRenderer
    end
    super *[collection_or_options, options].compact
  end

  def round_meters_up_to_5_mi(meters)
    five_miles_in_meters = 8046.72
    (meters / five_miles_in_meters).ceil * 5
  end

  def link_to_locale(locale, label, additional_attributes = {})
    link_to(label,
            { locale: locale, params: request.query_parameters },
            lang: locale,
            id: "locale_switcher_#{locale}",
            data: {
              track_click: "intake-language-changed",
              track_attribute_to_locale: locale,
              track_attribute_from_locale: I18n.locale,
            },
            **additional_attributes).html_safe
  end

  def link_to_spanish(additional_attributes={})
    link_to_locale('es', 'Español', additional_attributes)
  end

  def link_to_english(additional_attributes={})
    link_to_locale('en', 'English', additional_attributes)
  end

  def signature_methods_for_select
    Intake.signature_methods.map { |method| [I18n.t("hub.clients.fields.signature_methods.#{method[0]}"), method[0]]}
  end

  def flash_alerts
    "$('.flash-alerts').html('#{escape_javascript(render("shared/flash_alerts", flash: flash))}');".html_safe
  end

  def extends(layout, &block)
    # Make sure it's a string
    layout = layout.to_s

    # If there's no directory component, presume a plain layout name
    layout = "layouts/#{layout}" unless layout.include?('/')

    # Capture the content to be placed inside the extended layout
    @view_flow.get(:layout).replace(capture(&block) || '')

    render template: layout
  end

  def mask(string, unmasked_char_count = 0)
    return string unless string.present?

    string.gsub(/.(?=.{#{unmasked_char_count}})/, '●')
  end

  def ssn_mask(ssn)
    return I18n.t("general.NA") unless ssn.present?
    "XXX-XX-#{ssn.last(4)}"
  end

  def tin_options_for_select(include_ssn_no_employment: false, include_atin: false, include_itin: false, include_none: false)
    options = [
      [I18n.t("general.tin.ssn"), :ssn],
    ]
    options << [I18n.t("general.tin.ssn_no_employment"), :ssn_no_employment] if include_ssn_no_employment
    options << [I18n.t("general.tin.atin"), :atin] if include_atin
    options << [I18n.t("general.tin.itin"), :itin] if include_itin
    options << [I18n.t("general.tin.none"), :none] if include_none
    options
  end

  def months_in_home_options_for_select
    # if the dependent lived with a client more than half the year but less than 7 months Schedule EIC wants us to mark it as "7"
    {I18n.t("views.ctc.questions.dependents.child_residence.select_options.less_than_six") => 6, I18n.t("views.ctc.questions.dependents.child_residence.select_options.six") => 7, I18n.t("views.ctc.questions.dependents.child_residence.select_options.seven") => 7, I18n.t("views.ctc.questions.dependents.child_residence.select_options.eight") => 8, I18n.t("views.ctc.questions.dependents.child_residence.select_options.nine") => 9, I18n.t("views.ctc.questions.dependents.child_residence.select_options.ten") => 10, I18n.t("views.ctc.questions.dependents.child_residence.select_options.eleven") => 11, I18n.t("views.ctc.questions.dependents.child_residence.select_options.twelve") => 12}
  end

  def suffix_options_for_select
    ["I", "II", "III", "IV", "V", "Jr", "Sr"]
  end

  def suffix_options_for_state_select
    ["JR", "SR", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
  end

  def yes_no_unsure_options_for_select
    [
      ["", "unfilled"],
      [I18n.t("general.affirmative"), "yes"],
      [I18n.t("general.negative"), "no"],
      [I18n.t("general.unsure"), "unsure"],
    ]
  end

  def short_yes_no_unsure_options_for_select
    [
      ["", "unfilled"],
      ['Y', "yes"],
      ['N', "no"],
      ['?', "unsure"],
    ]
  end

  def payment_options_for_select
    [
      ["", "unfilled"],
      ["Bank account", "yes"],
      ["Set up installment agreement", "installments"],
      ["Mail payment to IRS", "no"],
    ]
  end

  def yes_no_options_for_select
    [
      ["", "unfilled"],
      [I18n.t("general.affirmative"), "yes"],
      [I18n.t("general.negative"), "no"],
    ]
  end

  def yes_no_na_options_for_select
    [
      ["", "unfilled"],
      [I18n.t("general.affirmative"), "yes"],
      [I18n.t("general.negative"), "no"],
      ["N/A", "na"],
    ]
  end

  def yes_no_prefer_not_to_answer_options_for_select
    [
      ["", "unfilled"],
      [I18n.t("general.affirmative"), "yes"],
      [I18n.t("general.negative"), "no"],
      [I18n.t("general.prefer_not_to_answer"), "prefer_not_to_answer"],
    ]
  end

  def submission_status_icon(status)
    case status
    when "intake_in_progress", "fraud_hold"
      "icons/in-progress.svg"
    when "failed", "bundle_failure"
      "icons/exclamation.svg"
    when "rejected"
      "icons/rejected.svg"
    when "accepted"
      "icons/accepted.svg"
    when "cancelled"
      "icons/cancelled.svg"
    when "new", "preparing", "transmitted", "bundling"
      "icons/sending.svg"
    end
  end

  def ctc_current_tax_year
    MultiTenantService.new(:ctc).current_tax_year
  end

  def ctc_prior_tax_year
    MultiTenantService.new(:ctc).prior_tax_year
  end

  def request_domain
    request.domain
  end
end
