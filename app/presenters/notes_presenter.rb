class NotesPresenter
  def self.grouped_notes(client)
    # Extract Note and SystemNote data from the database.
    # Generate notes from documents on-the-fly, so the summary can change as clients upload more documents.
    notes = (client.notes.includes(:user) + SystemNote.where(client: client))
    synthetic_notes = SyntheticNote.from_client_documents(client)
    synthetic_notes += SyntheticNote.from_outbound_calls(client)
    synthetic_notes += SyntheticNote.from_verification_attempts(client)
    (notes + synthetic_notes).flatten.sort_by(&:created_at).group_by { |note| note.created_at.beginning_of_day }
  end
end
