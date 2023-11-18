class MessagePresenter
  def self.grouped_messages(client)
    messages = (
      client.outgoing_text_messages.includes(:user) +
      IncomingTextMessage.where(phone_number: client.phone_number) +
      client.outgoing_emails.includes(:user) +
      client.incoming_emails +
      client.incoming_portal_messages +
      SystemNote::SignedDocument.where(client: client) +
      SyntheticNote.from_client_documents(client) +
      SyntheticNote.from_outbound_calls(client) +
      SyntheticNote.from_deleted_client_documents(client)
    )
    messages.sort_by(&:datetime).group_by { |message| message.datetime.beginning_of_day }
  end
end