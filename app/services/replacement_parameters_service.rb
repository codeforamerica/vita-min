class ReplacementParametersService
  attr_accessor :body, :client, :preparer_user, :locale

  def initialize(body:, client:, preparer: nil, locale: "en")
    @body = body
    @client = client
    @preparer_user = preparer
    @locale = locale
  end

  def process
    replacements.each_key { |k| body.gsub!(/<<\s*#{k}\s*>>/i, "%{#{k}}") }
    body % replacements
  end

  private

  def replacements
    {
        "Client.PreferredName": client&.preferred_name,
        "Preparer.FirstName": preparer_first_name,
        "Documents.List": documents_list,
        "Documents.UploadLink": client.intake.requested_docs_token_link
    }
  end

  def preparer_first_name
    preparer_user&.first_name || I18n.t("general.tax_team", locale: locale)
  end

  def documents_list
    client.intake.relevant_document_types.map do |doc_type|
      "  - " + doc_type.translated_label(locale)
    end.join("\n")
  end
end
