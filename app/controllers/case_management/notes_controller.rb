module CaseManagement
  class NotesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in, :require_beta_tester
    layout "admin"

    def index
      @client = Client.find(params[:client_id])
      @notes = @client.notes
      @note = Note.new
    end

    def create
      @client = Client.find(params[:client_id])
      @note = Note.new(note_params)
      return render :index unless @note.save

      redirect_to case_management_client_notes_path(client_id: params[:client_id])
    end

    private

    def note_params
      params.require(:note).permit(:body).merge(user: current_user, client: @client)
    end
  end
end
