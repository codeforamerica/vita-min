class SyntheticNote
  attr_accessor :created_at, :body, :contact_record_type, :user, :heading, :contact_record
  delegate :verification_attempt_path, to: "Rails.application.routes.url_helpers"

  def initialize(created_at:, body: nil, contact_record_type: nil, contact_record: nil, user: nil, heading: nil)
    @created_at = created_at
    @body = body
    @contact_record_type = contact_record_type
    @contact_record = contact_record
    @user = user
    @heading = heading
  end

  def self.from_verification_attempts(client)
    notes = []
    verification_attempts = client.verification_attempts.includes(:transitions).order(created_at: :asc)
    verification_attempts.each do |attempt|
      notes << SyntheticNote.new(
        created_at: attempt.created_at,
        contact_record: attempt
      )
      attempt.transitions.each do |transition|
        notes << SyntheticNote.new(
          created_at: transition.created_at,
          contact_record: transition
        )
      end
    end
    notes
  end

  def self.from_client_documents(client)
    grouped = client.documents.order(created_at: :asc).where(uploaded_by: client).group_by { |doc| doc.created_at.beginning_of_day }
    grouped.map do |_, values|
      # Use most recent Document created_at as note created_at
      SyntheticNote.new(
        created_at: values[-1].created_at,
        body: I18n.t("hub.notes.index.document_note", count: values.length),
        contact_record_type: "system_note"
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
      body = I18n.t("hub.notes.index.outbound_call_synthetic_note", user_name: outbound_call.user.name_with_role, client_name: client.preferred_name, status: outbound_call.twilio_status, duration: duration)
      body += "\n#{I18n.t("hub.notes.index.outbound_call_synthetic_note_body")}\n#{outbound_call.note}" if outbound_call.note.present?
      SyntheticNote.new(
        created_at: outbound_call.created_at,
        body: body,
        contact_record_type: "outbound_call",
        heading: "#{I18n.t("hub.messages.to")} #{outbound_call.to}",
        user: outbound_call.user
        )
    end.compact
  end

  def datetime
    @created_at
  end

end
