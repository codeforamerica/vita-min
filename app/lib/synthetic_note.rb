class SyntheticNote
  attr_accessor :created_at
  attr_accessor :body

  def initialize(created_at, body)
    @created_at = created_at
    @body = body
  end

  def self.from_client_documents(client)
    grouped = client.documents.order(created_at: :asc).where(uploaded_by: client).group_by { |doc| doc.created_at.beginning_of_day }
    grouped.map do |_, values|
      # Use most recent Document created_at as note created_at
      SyntheticNote.new(
          values[-1].created_at,
          I18n.t("hub.notes.index.document_note", count: values.length)
      )
    end
  end

  def self.from_outbound_calls(client)
    outbound_calls = client.outbound_calls.order(created_at: :asc)
    outbound_calls.map do |outbound_call|
      next if outbound_call.twilio_status == "queued"

      duration = ""
      if outbound_call.twilio_call_duration
        duration_minutes = outbound_call.twilio_call_duration / 60
        duration_seconds = outbound_call.twilio_call_duration % 60
        duration += "#{duration_minutes}m" if duration_minutes.positive?
        duration += "#{duration_seconds}s"
      end
      body = I18n.t("hub.notes.index.outbound_call_synthetic_note", user_name: outbound_call.user.name, client_name: outbound_call.client.preferred_name, status: outbound_call.twilio_status, duration: duration)
      body += "\n#{I18n.t("hub.notes.index.outbound_call_synthetic_note_body")}\n#{outbound_call.note}}" if outbound_call.note.present?
      SyntheticNote.new(outbound_call.created_at, body)
    end.compact
  end
end