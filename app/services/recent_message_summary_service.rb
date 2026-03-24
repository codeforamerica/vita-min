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

      summaries[client_id] = { author: message.author, body: message.body || "", date: message.created_at } unless message.nil?
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
        SELECT DISTINCT ON (incoming_emails.client_id)
          incoming_emails.id, incoming_emails.client_id, incoming_emails.created_at,
          incoming_emails.body_plain AS message_body, intakes.preferred_name AS prefetched_author
        FROM incoming_emails
        INNER JOIN intakes ON intakes.client_id = incoming_emails.client_id
        WHERE incoming_emails.client_id IN ( ? )
        ORDER BY incoming_emails.client_id, incoming_emails.created_at DESC
      SQL
    end
  end

  def self.summarize_incoming_text_messages(client_ids)
    summarize(client_ids) do
      IncomingTextMessage.find_by_sql([<<~SQL, client_ids])
        SELECT DISTINCT ON (incoming_text_messages.client_id)
          incoming_text_messages.id, incoming_text_messages.client_id,
          incoming_text_messages.body AS message_body, incoming_text_messages.created_at,
          intakes.preferred_name AS prefetched_author
        FROM incoming_text_messages
        INNER JOIN intakes ON intakes.client_id = incoming_text_messages.client_id
        WHERE incoming_text_messages.client_id IN ( ? )
        ORDER BY incoming_text_messages.client_id, incoming_text_messages.created_at DESC
      SQL
    end
  end

  def self.summarize_outgoing_emails(client_ids)
    summarize(client_ids) do
      OutgoingEmail.find_by_sql([<<~SQL, client_ids])
        SELECT DISTINCT ON (outgoing_emails.client_id)
          outgoing_emails.id, outgoing_emails.client_id,
          outgoing_emails.body AS message_body, outgoing_emails.created_at,
          user_id, users.name AS prefetched_author
        FROM outgoing_emails
        INNER JOIN users ON users.id = user_id
        WHERE outgoing_emails.client_id IN ( ? )
        ORDER BY outgoing_emails.client_id, outgoing_emails.created_at DESC
      SQL
    end
  end

  def self.summarize_outgoing_text_messages(client_ids)
    summarize(client_ids) do
      OutgoingTextMessage.find_by_sql([<<~SQL, client_ids])
        SELECT DISTINCT ON (outgoing_text_messages.client_id)
          outgoing_text_messages.id, outgoing_text_messages.client_id,
          outgoing_text_messages.body AS message_body, outgoing_text_messages.created_at,
          user_id, users.name AS prefetched_author
        FROM outgoing_text_messages
        INNER JOIN users ON users.id = user_id
        WHERE outgoing_text_messages.client_id IN ( ? )
        ORDER BY outgoing_text_messages.client_id, outgoing_text_messages.created_at DESC
      SQL
    end
  end

  def self.summarize_incoming_portal_messages(client_ids)
    summarize(client_ids) do
      IncomingPortalMessage.find_by_sql([<<~SQL, client_ids])
        SELECT DISTINCT ON (incoming_portal_messages.client_id)
          incoming_portal_messages.id, incoming_portal_messages.client_id,
          incoming_portal_messages.body AS message_body, incoming_portal_messages.created_at,
          intakes.preferred_name AS prefetched_author
        FROM incoming_portal_messages
        INNER JOIN intakes ON intakes.client_id = incoming_portal_messages.client_id
        WHERE incoming_portal_messages.client_id IN ( ? )
        ORDER BY incoming_portal_messages.client_id, incoming_portal_messages.created_at DESC
      SQL
    end
  end
end
