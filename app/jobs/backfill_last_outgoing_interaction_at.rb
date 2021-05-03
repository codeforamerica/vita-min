class BackfillLastOutgoingInteractionAt < ApplicationJob
  def perform(start: 0, finish: nil)
    Client.includes(:outbound_calls, :outgoing_text_messages, :outgoing_emails).find_each(start: start, finish: finish) do |client|
      if client.last_outgoing_interaction_at.present?
        puts "SKIPPING #{client.id}: last_outgoing_interaction_at is already set."
        next
      end

      # Looking for the most recent of each outgoing interaction.
      text = client.outgoing_text_messages.last&.created_at
      email = client.outgoing_emails.last&.created_at
      call = client.outbound_calls.last&.created_at

      last_interaction_timestamp = [text, email, call].compact.max

      if last_interaction_timestamp.present?
        if client.update(last_outgoing_interaction_at: last_interaction_timestamp)
          puts "SUCCESS #{client.id}: updated last outgoing interaction to #{last_interaction_timestamp}"
        else
          puts "ERROR #{client.id}: could not persist last_outgoing_interaction to #{last_interaction_timestamp}"
        end
      else
        puts "SKIPPING #{client.id}: no interactions for #{client.id}."
      end
    end
  end
end