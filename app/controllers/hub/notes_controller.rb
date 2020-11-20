module Hub
  class NotesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client
    load_and_authorize_resource :system_note, parent: false, through: :client
    layout "admin"

    def index
      @all_notes = (@notes.includes(:user) + SystemNote.where(client: @client)).sort_by(&:created_at)
      @all_notes_by_day = @all_notes.group_by { |note| note.created_at.beginning_of_day }
      @note = Note.new
    end

    def create
      return render :index unless @note.save

      redirect_to hub_client_notes_path(client_id: params[:client_id])
    end

    private

    def note_params
      params.require(:note).permit(:body).merge(user: current_user, client: @client)
    end
  end
end
