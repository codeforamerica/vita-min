module Hub
  class AutomatedMessagesController < ApplicationController
    include AccessControllable

    layout "admin"
    load_and_authorize_resource class: false

    before_action :require_sign_in

    def index
      @messages = [
        {
          type: "getting_started",
          subject: I18n.t("messages.getting_started.email_subject"),
          email_body: I18n.t("messages.getting_started.email_body"),
          sms_body: I18n.t("messages.getting_started.sms_body"),
        },
        {
          type: "successful_submission_drop_off",
          subject: I18n.t("messages.successful_submission_drop_off.subject"),
          email_body: I18n.t("messages.successful_submission_drop_off.email_body"),
          sms_body: I18n.t("messages.successful_submission_drop_off.sms_body"),
        },
        {
          type: "successful_submission_online_intake",
          subject: I18n.t("messages.successful_submission_online_intake.subject"),
          email_body: I18n.t("messages.successful_submission_online_intake.email_body"),
          sms_body: I18n.t("messages.successful_submission_online_intake.sms_body"),
        },
        {
          type: "surveys.in_progress",
          subject: I18n.t("messages.surveys.in_progress.email.subject"),
          email_body: I18n.t("messages.surveys.in_progress.email.body"),
          sms_body: I18n.t("messages.surveys.in_progress.sms"),
        },
        {
          type: "surveys.completion",
          subject: I18n.t("messages.surveys.completion.email.subject"),
          email_body: I18n.t("messages.surveys.completion.email.body"),
          sms_body: I18n.t("messages.surveys.completion.sms"),
        }
      ]
    end
  end
end
