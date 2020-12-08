class NotesPresenter
  def self.grouped_notes(client)
    # Extract Note and SystemNote data from the database.
    # Generate notes from documents on-the-fly, so the summary can change as clients upload more documents.
    notes = (client.notes.includes(:user) + SystemNote.where(client: client))
    synthetic_notes = synthetic_notes_from_documents(client.documents.order(created_at: :asc))
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
