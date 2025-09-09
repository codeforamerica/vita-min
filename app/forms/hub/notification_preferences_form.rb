module Hub
  class NotificationPreferencesForm < Form
    attr_accessor :user
    attr_accessor :client_messages_notification,
                  :client_assignments_notification,
                  :document_uploads_notification,
                  :unsubscribe_all

    validate :notification_selected
    before_save :process_unsubscribe_all

    def initialize(user, params = {})
      @user = user
      super(params)
      load_from_user if params.empty?
    end

    def self.from_user(user)
      new(user)
    end

    def save
      return false unless valid?

      user.assign_attributes(notification_attributes)
      user.save
    end

    def self.permitted_params
      [:client_messages_notification, :client_assignments_notification, :document_uploads_notification, :unsubscribe_all]
    end


    def load_from_user
      return unless user

      self.client_messages_notification = user.client_messages_notification
      self.client_assignments_notification = user.client_assignments_notification
      self.document_uploads_notification = user.document_uploads_notification

      self.unsubscribe_all = client_messages_notification == 'no' &&
                             client_assignments_notification == 'no' &&
                             document_uploads_notification == 'no'
    end

    def notification_selected
      unless client_messages_notification == 'yes' || client_assignments_notification == 'yes' || document_uploads_notification == 'yes' || unsubscribe_all == "yes"
        errors.add(:base, I18n.t('hub.users.profile.error'))
      end
    end

    def process_unsubscribe_all
      if unsubscribe_all == "yes"
        self.client_messages_notification = 'no'
        self.client_assignments_notification = 'no'
        self.document_uploads_notification = 'no'
      end
    end


    def notification_attributes
      {
        client_messages_notification: client_messages_notification,
        client_assignments_notification: client_assignments_notification,
        document_uploads_notification: document_uploads_notification
      }
    end
  end
end