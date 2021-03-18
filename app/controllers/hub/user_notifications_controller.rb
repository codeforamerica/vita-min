module Hub
  class UserNotificationsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    after_action :mark_all_notifications_read, only: [:index]
    load_and_authorize_resource
    layout "admin"

    def index
      @page_title = "Notifications"
      @user_notifications = @user_notifications.order(created_at: :desc).page(params[:page])
    end

    def mark_all_notifications_read
      @user_notifications.update_all(read: true)
    end
  end
end