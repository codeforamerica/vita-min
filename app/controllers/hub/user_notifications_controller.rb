module Hub
  class UserNotificationsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource only: [:index]
    layout "admin"

    def index
      @page_title = "Notifications"
      @user_notifications = @user_notifications.order(created_at: :desc).page(params[:page])
    end

    def mark_all_notifications_read
      UserNotification.accessible_by(current_ability).update_all(read: true)

      redirect_to hub_user_notifications_path
    end
  end
end