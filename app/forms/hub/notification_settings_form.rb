module Hub
  class NotificationSettingsForm < Form
    attr_accessor :user
    attr_accessor :new_client_message_notification,
                  :client_assignments_notification,
                  :document_upload_notification,
                  :tagged_in_note_notification,
                  :signed_8879_notification,
                  :unsubscribe_all

    validate :notification_selected

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
      process_unsubscribe_all
      user.assign_attributes(notification_attributes)
      user.save
    end

    def self.permitted_params
      [:new_client_message_notification, :client_assignments_notification, :document_upload_notification, :tagged_in_note_notification, :signed_8879_notification, :unsubscribe_all]
    end


    def load_from_user
      return unless user

      self.new_client_message_notification = user.new_client_message_notification
      self.client_assignments_notification = user.client_assignments_notification
      self.document_upload_notification = user.document_upload_notification
      self.tagged_in_note_notification = user.tagged_in_note_notification
      self.signed_8879_notification = user.signed_8879_notification

      self.unsubscribe_all = new_client_message_notification == 'no' &&
                             client_assignments_notification == 'no' &&
                             document_upload_notification == 'no' &&
                             tagged_in_note_notification == 'no' &&
                             signed_8879_notification == 'no'
    end

    def notification_selected
      unless signed_8879_notification == 'yes' || tagged_in_note_notification == 'yes' || new_client_message_notification == 'yes' || client_assignments_notification == 'yes' || document_upload_notification == 'yes' || unsubscribe_all == "yes"
        errors.add(:base, I18n.t('hub.users.profile.error'))
      end
    end

    def process_unsubscribe_all
      if unsubscribe_all == "yes"
        self.new_client_message_notification = 'no'
        self.client_assignments_notification = 'no'
        self.document_upload_notification = 'no'
        self.tagged_in_note_notification = 'no'
        self.signed_8879_notification = 'no'
      end
    end


    def notification_attributes
      {
        new_client_message_notification: new_client_message_notification,
        client_assignments_notification: client_assignments_notification,
        document_upload_notification: document_upload_notification,
        tagged_in_note_notification: tagged_in_note_notification,
        signed_8879_notification: signed_8879_notification
      }
    end
  end
end