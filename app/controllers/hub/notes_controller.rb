module Hub
  class NotesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client, only: [:create]
    layout "admin"

    def index
      @all_notes_by_day = NotesPresenter.grouped_notes(@client)
      @note = Note.new
    end

    def create
      return render :index unless @note.save

      redirect_to hub_client_notes_path(client_id: params[:client_id], anchor: "last-item")
    end

    private

    def note_params
      params.require(:note).permit(:body).merge(user: current_user, client: @client)
    end
  end
end
