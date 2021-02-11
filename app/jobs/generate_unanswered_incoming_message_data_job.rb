class GenerateUnansweredIncomingMessageDataJob < ApplicationJob
  def perform(start: 0, finish: nil)
    Client.includes(:outbound_calls, :outgoing_text_messages, :outgoing_emails, :incoming_emails, :incoming_text_messages).find_each(start: start, finish: finish) do |client|
      if client.first_unanswered_incoming_correspondence_at.present?
        puts "SKIPPING #{client.id}: fuica already set."
        next
      end

      # If there are outbound messages present, we need to get the first inbound after the last outbound.
      # If there are no outbounds, we can use the first inbound.
      last_outbound = [client.outgoing_text_messages.last, client.outgoing_emails.last, client.outgoing_emails.last].compact.max_by { |msg| msg&.created_at }
      if last_outbound.present?
        itm = client.incoming_text_messages.find { |itm| itm.created_at > last_outbound.created_at }
        ie = client.incoming_emails.find { |ie| ie.created_at > last_outbound.created_at }
        fuica = [itm, ie].compact.min_by { |a| a&.created_at }
      else
        fuica = [client.incoming_text_messages.first, client.incoming_emails.first].compact.min_by { |msg| msg&.created_at }
      end

      if fuica.present?
        if client.update(first_unanswered_incoming_correspondence_at: fuica.created_at)
          puts "SUCCESS #{client.id}: updated fuica to #{fuica.created_at}"
        else
          puts "ERROR #{client.id}: could not persist fuica to #{fuica.created_at}"
        end
      else
        puts "SKIPPING #{client.id}: no unanswered messages for #{client.id}."
      end
    end
  end
end

# First email sent since the last time we responded.