module FilingStatusHelper
  def filing_status(client)
    if client.tax_returns.map(&:filing_status).any?
      content_tag :ul do
        client.tax_returns.collect do |tax_return|
          content_tag( :li, filing_status_tax_return(tax_return)) if tax_return.filing_status.present?
        end.compact.join.html_safe
      end
    else
      client.intake&.filing_joint == "yes" ? "Filing jointly" : "Not filing jointly"
    end
  end

  def filing_status_tax_return(tax_return)
    return nil unless tax_return.filing_status?

    content = content_tag(:strong, I18n.t("general.filing_status.#{tax_return.filing_status}"))
    content << content_tag(:span, " (#{tax_return.year})")
    content << content_tag(:div, (content_tag :i, tax_return.filing_status_note)) if tax_return.filing_status_note?
    content
  end

  def marital_status(client)
    intake = client.intake

    statuses = [
      (I18n.t("general.married") if intake.married == "yes"),
      (I18n.t("general.lived_with_spouse") if intake.lived_with_spouse == "yes"),
      ("#{I18n.t("general.separated")} #{intake.separated_year}" if intake.separated == "yes"),
      ("#{I18n.t("general.divorced")} #{intake.divorced_year}" if intake.divorced == "yes"),
      ("#{I18n.t("general.widowed")} #{intake.widowed_year}" if intake.widowed == "yes"),
      ("#{I18n.t("general.single")}" if intake.ever_married == "no")
    ].compact

    content_tag(:span, statuses.present? ? statuses.join(", ") : I18n.t("general.NA"))
  end
end