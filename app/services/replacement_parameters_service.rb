class ReplacementParametersService
  attr_accessor :body, :client, :preparer_user, :locale, :tax_return, :intake

  delegate :new_portal_client_login_url, :new_ctc_portal_client_login_url, to: "Rails.application.routes.url_helpers"

  def initialize(body:, client:, preparer: nil, tax_return: nil, locale: nil)
    @body = body
    @client = client
    @intake = client.intake.nil? ? Archived::Intake2021.where(client_id: client.id).first : client.intake
    @tax_return = tax_return
    @preparer_user = preparer
    @locale = locale || "en"
  end

  def process
    process_replacements_hash(replacements)
  end

  private

  def process_replacements_hash(replacements_hash)
    # escape existing percent signs
    body.gsub!(/%(?!{\S*})/, "%%")

    # replace valid <<key>> with %{key}
    replacements_hash.each_key { |key| body.gsub!(/<<\s*#{key}\s*>>/i, "%{#{key}}") }

    body % replacements_hash
  end

  def replacements
    {
        "Client.PreferredName": intake&.preferred_name&.titleize,
        "Preparer.FirstName": preparer_first_name,
        "Documents.List": documents_list,
        "Client.LoginLink": intake.is_ctc? ? new_ctc_portal_client_login_url(locale: locale, host: Rails.configuration.ctc_url) : new_portal_client_login_url(locale: locale),
        "Link.E-signature": new_portal_client_login_url(locale: locale),
        "GetYourRefund.PhoneNumber": OutboundCall.twilio_number,
        "TaxReturn.TaxYear": tax_return&.year,
        "Client.ClientId": client&.id,
        "Client.AssignedOrganization": client&.vita_partner&.name
    }
  end

  def preparer_first_name
    preparer_user&.first_name || I18n.t("general.tax_team", locale: locale)
  end

  def documents_list
    return if client.intake.nil?

    @intake.document_types_definitely_needed.map do |doc_type|
      "  - " + doc_type.translated_label_with_description(locale)
    end.join("\n")
  end
end
