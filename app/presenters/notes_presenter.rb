class NotesPresenter
  def self.grouped_notes(client)
    # Extract Note and SystemNote data from the database.
    # Generate notes from documents on-the-fly, so the summary can change as clients upload more documents.
    notes = (client.notes.includes(:user) + SystemNote.where(client: client))
    synthetic_notes = synthetic_notes_from_documents(client.documents.order(created_at: :asc))
    synthetic_notes += synthetic_notes_from_outbound_calls(client.outbound_calls.order(created_at: :asc))
    (notes + synthetic_notes).sort_by(&:created_at).group_by { |note| note.created_at.beginning_of_day }
  end

  private

  def self.synthetic_notes_from_documents(documents)
    grouped = documents.group_by { |doc| doc.created_at.beginning_of_day }
    grouped.map do |_, values|
      # Use most recent Document created_at as note created_at
      SyntheticNote.new(
        values[-1].created_at,
        I18n.t("hub.notes.index.document_note", count: values.length)
      )
    end
  end

  def self.synthetic_notes_from_outbound_calls(outbound_calls)
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

  # A SyntheticNote has enough information to be displayed in the page.
  class SyntheticNote
    attr_accessor :created_at
    attr_accessor :body

    def initialize(created_at, body)
      @created_at = created_at
      @body = body
    end
  end
end
