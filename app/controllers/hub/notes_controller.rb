module Hub
  class NotesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client, only: [:create]
    load_and_authorize_resource :user, parent: false, only: [:index]
    layout "admin"

    def index
      @taggable_users = @users.to_json(only: [:name, :id], methods: :name_with_role_and_entity).to_s.html_safe
      @all_notes_by_day = NotesPresenter.grouped_notes(@client)
      @note = Note.new
    end

    def create
      if @note.valid?
        @note.save!
        if params[:note][:mentioned_ids].present?
          mentioned_user_ids = params[:note][:mentioned_ids].split(",")
          mentioned_user_ids.each do |id|
            UserNotification.create(notifiable: @note, user_id: id)
          end
        end
      else
        return render :index
      end

      redirect_to hub_client_notes_path(client_id: params[:client_id], anchor: "last-item")
    end

    private

    def note_params
      params.require(:note).permit(:body).merge(user: current_user, client: @client)
    end
  end
end
