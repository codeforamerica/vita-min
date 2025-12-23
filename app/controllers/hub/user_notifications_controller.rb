module Hub
  class UserNotificationsController < Hub::BaseController
    layout "hub"
    after_action :flush_memoized_data, only: [:index]

    def index
      @page_title = I18n.t("hub.clients.navigation.notifications")
      cutoff = [
        app_time - 7.days,
        Date.new(Rails.configuration.product_year)
      ].min
      @user_notifications = current_user.notifications
                                        .where('created_at >= ?', cutoff)
                                        .order(created_at: :desc).page(params[:page])
    end

    def mark_all_notifications_read
      current_user.notifications.unread.update_all(read: true)

      redirect_to hub_user_notifications_path
    end

    private

    def flush_memoized_data
      @user_notifications.each(&:flush_memoized_data) if @user_notifications
    end
  end
end
