module CaseManagement
  class NotesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client
    layout "admin"

    def index
      @notes = @notes.order(:created_at).includes(:user)
      @notes_by_day = @notes.group_by { |note| note.created_at.in_time_zone(current_user.timezone).beginning_of_day }
      @note = Note.new
    end

    def create
      return render :index unless @note.save

      redirect_to case_management_client_notes_path(client_id: params[:client_id])
    end

    private

    def note_params
      params.require(:note).permit(:body).merge(user: current_user, client: @client)
    end
  end
end
