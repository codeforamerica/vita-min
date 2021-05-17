class RecentMessageSummaryService
  def self.messages(client_ids)
    summaries = {}
    client_ids.each do |client_id|
      outgoing_emails = OutgoingEmail.where(client_id: client_id).order(created_at: :desc).limit(1).load
      outgoing_text_messages = OutgoingTextMessage.where(client_id: client_id).order(created_at: :desc).limit(1).load
      incoming_emails = IncomingEmail.where(client_id: client_id).order(created_at: :desc).limit(1).load
      incoming_text_messages = IncomingTextMessage.where(client_id: client_id).order(created_at: :desc).limit(1).load
      communications = (outgoing_emails + outgoing_text_messages + incoming_emails + incoming_text_messages).sort_by(&:created_at)
      unless communications.empty?
        message = communications.last

        if [OutgoingEmail, OutgoingTextMessage].include?(message.class)
          summaries[client_id] = { author: message.user.name, body: message.body, date: message.created_at }
        elsif [IncomingEmail].include?(message.class)
          summaries[client_id] = { author: message.client.preferred_name, body: message.body_plain, date: message.created_at }
        elsif [IncomingTextMessage].include?(message.class)
          summaries[client_id] = { author: message.client.preferred_name, body: message.body, date: message.created_at }
        end
      end
    end

    summaries
  end
end
