module Hub
  class NotificationsController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    #after action for marking notifications as read after page loads
    #add notifications to ability file and load and authorize here
    layout "admin"

    def index
      @page_title = "Notifications"
      @all_notifications_by_day = group_notifications(current_user)
    end

    # move to erb or keep here
    def group_notifications(user)
      notifications = UserNotification.where(user: user)
      notifications.sort_by(&:created_at).group_by do |notification|
        notification.created_at.beginning_of_day
      end
    end
  end
end