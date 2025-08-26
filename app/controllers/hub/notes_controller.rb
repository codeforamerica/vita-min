module Hub
  class NotesController < Hub::BaseController
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client
    load_and_authorize_resource :user, parent: false, only: [:index]
    layout "hub"

    def index
      @client = HubClientPresenter.new(@client)
      @note = Note.new
    end

    def create
      unless @note.save
        @client = HubClientPresenter.new(@client)
        return render :index
      end

      create_notifications if params.dig(:note, :mentioned_ids).present?
      redirect_to hub_client_notes_path(client_id: params[:client_id], anchor: "last-item")
    end

    private

    def note_params
      params.require(:note).permit(:body).merge(user: current_user, client: @client)
    end

    def create_notifications
      mentioned_user_ids = params.dig(:note, :mentioned_ids).split(",")
      mentioned_user_ids.each do |id|
        UserNotification.create(notifiable: @note, user_id: id)
        mentioned_user = User.find(id)
        InteractionTrackingService.record_internal_interaction(@note.client, user: mentioned_user, interaction_type: "tagged_in_note", received_at: @note.created_at) if mentioned_user
      end
    end

    class HubClientPresenter < Hub::ClientsController::HubClientPresenter
      def all_notes_by_day
        NotesPresenter.grouped_notes(self)
      end

      def taggable_users
        @_taggable_users ||= User.taggable_for(self).to_json(only: [:name, :id], methods: [:name_with_role_and_entity, :name_with_role]).to_s.html_safe
      end
    end
  end
end
