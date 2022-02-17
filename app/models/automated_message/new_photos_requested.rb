module AutomatedMessage
  class NewPhotosRequested < AutomatedMessage
    def self.name
      'messages.new_photos_requested'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.new_photos_requested.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.new_photos_requested.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.new_photos_requested.email.body", *args)
    end
  end
end