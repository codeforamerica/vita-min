class RecentMessageSummaryService
  def self.messages(client_ids)
    summaries = {}
    outgoing_emails = summarize_outgoing_emails(client_ids)
    outgoing_text_messages = summarize_outgoing_text_messages(client_ids)
    incoming_emails = summarize_incoming_emails(client_ids)
    incoming_text_messages = summarize_incoming_text_messages(client_ids)
    client_ids.each do |client_id|
      message = ([outgoing_emails[client_id]] + [outgoing_text_messages[client_id]] + [incoming_emails[client_id]] + [incoming_text_messages[client_id]]).compact.sort_by(&:created_at).last

      summaries[client_id] = { author: message.author, body: message.body, date: message.created_at } unless message.nil?
    end

    summaries
  end

  private

  SummarizedMessage = Struct.new(:created_at, :body, :author, :client_id)

  def self.summarize_outgoing_emails(client_ids)
    summaries = {}
    OutgoingEmail.find_by_sql(
      [
        "select outgoing_emails.id, outgoing_emails.client_id, outgoing_emails.body, outgoing_emails.created_at, user_id, users.name as prefetched_author from outgoing_emails inner join users on users.id = user_id where outgoing_emails.created_at IN (select max(outgoing_emails.created_at) from outgoing_emails group by client_id having client_id in ( ? ))",
        client_ids,
      ]
    ).each do |msg|
      if summaries[msg.client_id].nil? || summaries[msg.client_id].created_at < msg.created_at
        summaries[msg.client_id] = SummarizedMessage.new(msg.created_at, msg.body, msg.prefetched_author)
      end
    end

    summaries
  end

  def self.summarize_outgoing_text_messages(client_ids)
    summaries = {}
    OutgoingTextMessage.find_by_sql(
      [
        "select outgoing_text_messages.id, outgoing_text_messages.client_id, outgoing_text_messages.body, outgoing_text_messages.created_at, user_id, users.name as prefetched_author from outgoing_text_messages inner join users on users.id = user_id where outgoing_text_messages.created_at IN (select max(outgoing_text_messages.created_at) from outgoing_text_messages group by client_id having client_id in ( ? ))",
        client_ids,
      ]
    ).each do |msg|
      if summaries[msg.client_id].nil? || summaries[msg.client_id].created_at < msg.created_at
        summaries[msg.client_id] = SummarizedMessage.new(msg.created_at, msg.body, msg.prefetched_author)
      end
    end

    summaries
  end

  def self.summarize_incoming_emails(client_ids)
    summaries = {}
    IncomingEmail.find_by_sql(
      [
        "select incoming_emails.id, incoming_emails.client_id, incoming_emails.body_plain, incoming_emails.created_at, intakes.preferred_name as prefetched_author from incoming_emails inner join intakes on intakes.client_id = incoming_emails.client_id where incoming_emails.created_at IN (select max(incoming_emails.created_at) from incoming_emails group by incoming_emails.client_id having incoming_emails.client_id in ( ? ))",
        client_ids,
      ]
    ).each do |msg|
      if summaries[msg.client_id].nil? || summaries[msg.client_id].created_at < msg.created_at
        summaries[msg.client_id] = SummarizedMessage.new(msg.created_at, msg.body_plain, msg.prefetched_author)
      end
    end

    summaries
  end

  def self.summarize_incoming_text_messages(client_ids)
    summaries = {}
    IncomingTextMessage.find_by_sql(
      [
        "select incoming_text_messages.id, incoming_text_messages.client_id, incoming_text_messages.body, incoming_text_messages.created_at, intakes.preferred_name as prefetched_author from incoming_text_messages inner join intakes on intakes.client_id = incoming_text_messages.client_id where incoming_text_messages.created_at IN (select max(incoming_text_messages.created_at) from incoming_text_messages group by incoming_text_messages.client_id having incoming_text_messages.client_id in ( ? ))",
        client_ids,
      ]
    ).each do |msg|
      if summaries[msg.client_id].nil? || summaries[msg.client_id].created_at < msg.created_at
        summaries[msg.client_id] = SummarizedMessage.new(msg.created_at, msg.body, msg.prefetched_author)
      end
    end

    summaries
  end
end
