module AutomatedMessage
  class JoinResponse < AutomatedMessage
    def self.name
      'messages.join_keyword_response'.freeze
    end

    def sms_body
      I18n.t("messages.join_keyword_response.sms.body")
    end
  end
end
