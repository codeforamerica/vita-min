class MessagePresenter
  def self.grouped_messages(client)

    # @contact_history = (
    #         @outgoing_text_messages.includes(:user) +
    #         @incoming_text_messages +
    #         @outgoing_emails.includes(:user) +
    #         @incoming_emails
    #       ).sort_by(&:datetime)
    #       @messages_by_day = @contact_history.group_by { |message| message.datetime.beginning_of_day }
    #
    # Extract Note and SystemNote data from the database.
    # Generate notes from documents on-the-fly, so the summary can change as clients upload more documents.
    messages = (
      client.outgoing_text_messages.includes(:user) +
      client.incoming_text_messages +
      client.outgoing_emails.includes(:user) +
      client.incoming_emails
    )
    # synthetic_notes = SyntheticNote.from_client_documents(client)
    synthetic_notes = SyntheticNote.from_outbound_calls(client)
    (messages +synthetic_notes).sort_by(&:datetime).group_by { |message| message.datetime.beginning_of_day }
  end
end

# { date => [messages], date2 => [messages]}