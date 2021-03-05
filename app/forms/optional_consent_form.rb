class OptionalConsentForm < QuestionsForm
  set_attributes_for(
    :consent,
    :ip,
    :disclose_consented,
    :global_carryforward_consented,
    :relational_efin_consented,
    :use_consented,
    :user_agent
  )

  def save
    attributes = attributes_for(:consent)

    current_time = DateTime.now
    consent_attrs = {
      disclose_consented_at: attributes[:disclose_consented] == "true" ? current_time : nil,
      global_carryforward_consented_at: attributes[:global_carryforward_consented] == "true" ? current_time : nil,
      relational_efin_consented_at: attributes[:relational_efin_consented] == "true" ? current_time : nil,
      use_consented_at: attributes[:use_consented] == "true" ? current_time : nil,
      user_agent: attributes[:user_agent],
      ip: attributes[:ip]
    }
    intake.client.consent.present? ?
      intake.client.consent.update(consent_attrs) :
      intake.client.create_consent(consent_attrs)
  end
end
