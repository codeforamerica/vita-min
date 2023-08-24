# Oops! last_interaction_at was capturing incoming_interactions as well as internal and outgoing interactions,
# So we didn't really have a value that isolates internal/outgoing interactions with the client for our SLA comparison metrics.
# For "last touch time" to a client overall, we can rely on the client updated_at value which gets touched by default on each of the updates to the client object.

class BackfillAppropriateLastInteractionValue < ApplicationJob
  def perform(start: 0, finish: nil)
    Client.includes(:outbound_calls, :outgoing_text_messages, :outgoing_emails, :tax_returns, :notes, :documents).find_each(start: start, finish: finish) do |client|
      if client.last_internal_or_outgoing_interaction_at.present? && client.last_incoming_interaction_at != client.last_internal_or_outgoing_interaction_at
        puts "SKIPPING #{client.id}: last_interaction_at was not set from an incoming interaction."
        next
      end

      # Looking for the most recent of each interactionable item.
      itm = client.outgoing_text_messages.last&.created_at
      ie = client.outgoing_emails.last&.created_at
      doc = client.documents.reverse.find { |doc| doc.uploaded_by && doc.uploaded_by != client }&.created_at
      call = client.outbound_calls.last&.created_at
      note = client.notes.last&.created_at
      tax_return = client.tax_returns.max_by { |tr| tr&.updated_at }&.updated_at

      last_interaction_timestamp = [itm, ie, doc, call, note, tax_return].compact.max_by { |msg| msg }

      if last_interaction_timestamp.present?
        if client.update(last_internal_or_outgoing_interaction_at: last_interaction_timestamp)
          puts "SUCCESS #{client.id}: updated last interaction to #{last_interaction_timestamp}"
        else
          puts "ERROR #{client.id}: could not persist last_interaction to #{last_interaction_timestamp}"
        end
      else
        puts "SKIPPING #{client.id}: no interactions for #{client.id}."
      end
    end
  end
end

# First email sent since the last time we responded.