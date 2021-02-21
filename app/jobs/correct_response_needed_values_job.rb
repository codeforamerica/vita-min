class CorrectResponseNeededValuesJob < ApplicationJob
  def perform
    clients = Client.includes(:documents, :outbound_calls, :outgoing_text_messages, :outgoing_emails, :incoming_emails, :incoming_text_messages)
    clients.find_each do |client|
      incoming_sms_times = client.incoming_text_messages.pluck(:received_at)
      incoming_email_times = client.incoming_emails.pluck(:received_at)
      incoming_doc_times = Document.where(uploaded_by: client).pluck(:created_at)
      incoming_times = (incoming_sms_times + incoming_email_times + incoming_doc_times).compact
      latest_incoming_time = incoming_times.max

      next unless latest_incoming_time.present?

      # we shouldn't count automated messages as responses, so exclude user: nil
      last_outgoing_sms_time = client.outgoing_text_messages.where.not(user: nil).order(sent_at: :desc).first&.sent_at
      last_outgoing_email_time = client.outgoing_emails.where.not(user: nil).order(sent_at: :desc).first&.sent_at
      last_outbound_call_time = client.outbound_calls.order(created_at: :desc).first&.created_at
      latest_outgoing_time = [last_outgoing_sms_time, last_outgoing_email_time, last_outbound_call_time].compact.max

      if latest_outgoing_time.blank?
        earliest_incoming_time = incoming_times.min
        client.update(first_unanswered_incoming_interaction_at: earliest_incoming_time)
      elsif latest_incoming_time > latest_outgoing_time
        # client acted last
        # set needs response to earliest incoming time after last outgoing time
        client.update(first_unanswered_incoming_interaction_at: incoming_times.filter { |t| t > latest_outgoing_time }.min)
      else
        # user acted last, so we should clear it if it's a false positive
        client.update(first_unanswered_incoming_interaction_at: nil)
      end
    end
  end
end