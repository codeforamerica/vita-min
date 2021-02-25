class ReplacementParametersService
  attr_accessor :body, :client, :preparer_user, :locale

  def initialize(body:, client:, preparer: nil, locale: "en")
    @body = body
    @client = client
    @preparer_user = preparer
    @locale = locale
  end

  def process
    process_replacements_hash(replacements)
  end

  def process_sensitive_data
    process_replacements_hash(sensitive_replacements)
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
        "Client.PreferredName": client&.preferred_name,
        "Preparer.FirstName": preparer_first_name,
        "Documents.List": documents_list,
        "Documents.UploadLink": client.intake.requested_docs_token_link,
        "Client.YouOrMaybeYourSpouse": you_or_your,
    }
  end

  def you_or_your
    value = client.intake.filing_joint_yes? ? I18n.t("general.you_or_spouse") : I18n.t("general.you")
    value.capitalize
  end

  # this should only be called when we aren't saving the output to our database
  # for example, when adding a link to send to the client only
  def sensitive_replacements
    if body.match(/<<\s*Link\.E-signature\s*>>/i)
      {
        "Link.E-signature": client.generate_login_link,
      }
    else
      {}
    end
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
