module Hub
  class UserNotificationsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def index
      @page_title = I18n.t("hub.clients.navigation.notifications")
      @user_notifications = current_user.notifications.order(created_at: :desc).page(params[:page])
    end

    def mark_all_notifications_read
      current_user.notifications.unread.update_all(read: true)

      redirect_to hub_user_notifications_path
    end
  end
end