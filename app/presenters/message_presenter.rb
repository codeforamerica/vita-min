class MessagePresenter
  def self.grouped_messages(client)
    messages = (
      client.outgoing_text_messages.includes(:user) +
      client.incoming_text_messages +
      client.outgoing_emails.includes(:user) +
      client.incoming_emails +
      SystemNote::SignedDocument.where(client: client)
    )
    synthetic_notes = SyntheticNote.from_outbound_calls(client)
    (messages + synthetic_notes).sort_by(&:datetime).group_by { |message| message.datetime.beginning_of_day }
  end
end