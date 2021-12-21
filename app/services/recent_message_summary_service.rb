class RecentMessageSummaryService
  def self.messages(client_ids)
    summaries = {}
    incoming_emails = summarize_incoming_emails(client_ids)
    incoming_text_messages = summarize_incoming_text_messages(client_ids)
    outgoing_emails = summarize_outgoing_emails(client_ids)
    outgoing_text_messages = summarize_outgoing_text_messages(client_ids)
    incoming_portal_messages = summarize_incoming_portal_messages(client_ids)
    client_ids.each do |client_id|
      message = ([outgoing_emails[client_id]] + [outgoing_text_messages[client_id]] + [incoming_emails[client_id]] + [incoming_text_messages[client_id]] + [incoming_portal_messages[client_id]]).compact.sort_by(&:created_at).last

      summaries[client_id] = { author: message.author, body: message.body, date: message.created_at } unless message.nil?
    end

    summaries
  end

  private

  SummarizedMessage = Struct.new(:created_at, :body, :author, :client_id)

  def self.summarize(client_ids)
    summaries = {}

    yield(client_ids).each do |msg|
      if summaries[msg.client_id].nil? || summaries[msg.client_id].created_at < msg.created_at
        summaries[msg.client_id] = SummarizedMessage.new(msg.created_at, msg.message_body, msg.prefetched_author)
      end
    end

    summaries
  end

  def self.summarize_incoming_emails(client_ids)
    summarize(client_ids) do
      IncomingEmail.find_by_sql([<<~SQL, client_ids])
        SELECT incoming_emails.id, incoming_emails.client_id, incoming_emails.created_at, incoming_emails.body_plain as message_body, intakes.preferred_name as prefetched_author from incoming_emails
        INNER JOIN intakes ON intakes.client_id = incoming_emails.client_id
        WHERE incoming_emails.created_at IN (
          select max(incoming_emails.created_at)
          from incoming_emails
          group by incoming_emails.client_id
          having incoming_emails.client_id in ( ? )
        )
      SQL
    end
  end

  def self.summarize_incoming_text_messages(client_ids)
    summarize(client_ids) do
      IncomingTextMessage.find_by_sql([<<~SQL, client_ids])
        SELECT incoming_text_messages.id, incoming_text_messages.client_id, incoming_text_messages.body as message_body, incoming_text_messages.created_at, intakes.preferred_name as prefetched_author
        FROM incoming_text_messages
        INNER JOIN intakes on intakes.client_id = incoming_text_messages.client_id
        WHERE incoming_text_messages.created_at IN (
          select max(incoming_text_messages.created_at)
          from incoming_text_messages
          group by incoming_text_messages.client_id
          having incoming_text_messages.client_id in ( ? )
        )
      SQL
    end
  end

  def self.summarize_outgoing_emails(client_ids)
    summarize(client_ids) do
      OutgoingEmail.find_by_sql([<<~SQL, client_ids])
        SELECT outgoing_emails.id, outgoing_emails.client_id, outgoing_emails.body as message_body, outgoing_emails.created_at, user_id, users.name as prefetched_author
        FROM outgoing_emails
        INNER JOIN users on users.id = user_id
        WHERE outgoing_emails.created_at IN (
          select max(outgoing_emails.created_at)
          from outgoing_emails
          group by client_id
          having client_id in ( ? )
        )
      SQL
    end
  end

  def self.summarize_outgoing_text_messages(client_ids)
    summarize(client_ids) do
      OutgoingTextMessage.find_by_sql([<<~SQL, client_ids])
        SELECT outgoing_text_messages.id, outgoing_text_messages.client_id, outgoing_text_messages.body as message_body, outgoing_text_messages.created_at, user_id, users.name as prefetched_author
        FROM outgoing_text_messages
        INNER JOIN users on users.id = user_id
        WHERE outgoing_text_messages.created_at IN (
          select max(outgoing_text_messages.created_at)
          from outgoing_text_messages
          group by client_id
          having client_id in ( ? )
        )
      SQL
    end
  end

  def self.summarize_incoming_portal_messages(client_ids)
    summarize(client_ids) do
      IncomingTextMessage.find_by_sql([<<~SQL, client_ids])
        SELECT incoming_portal_messages.id, incoming_portal_messages.client_id, incoming_portal_messages.body as message_body, incoming_portal_messages.created_at, intakes.preferred_name as prefetched_author
        FROM incoming_portal_messages
        INNER JOIN intakes on intakes.client_id = incoming_portal_messages.client_id
        WHERE incoming_portal_messages.created_at IN (
          select max(incoming_portal_messages.created_at)
          from incoming_portal_messages
          group by incoming_portal_messages.client_id
          having incoming_portal_messages.client_id in ( ? )
        )
      SQL
    end
  end
end
