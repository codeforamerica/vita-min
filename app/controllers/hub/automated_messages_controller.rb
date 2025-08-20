module Hub
  class AutomatedMessagesController < Hub::BaseController
    before_action :require_admin
    layout "hub"

    def index
      @messages = messages_preview
    end

    private

    def messages_preview
      Rails.application.eager_load!
      automated_message_subclasses = AutomatedMessage::AutomatedMessage.descendants
      survey_message_classes = [SurveyMessages::GyrCompletionSurvey, SurveyMessages::CtcExperienceSurvey]

      message_classes = automated_message_subclasses + survey_message_classes
      automated_messages_and_mailers = message_classes.to_h do |klass|
        replaced_body = klass.new.email_body.gsub('<<', '&lt;&lt;').gsub('>>', '&gt;&gt;')
        email = OutgoingEmail.new(to: "example@example.com", body: replaced_body, subject: klass.new.email_subject, client: Client.new(intake: Intake::GyrIntake.new))
        [klass, OutgoingEmailMailer.user_message(outgoing_email: email)]
      end.to_h

      emails = {
        "UserMailer.assignment_email" => UserMailer.assignment_email(assigned_user: User.last, assigning_user: User.first, tax_return: TaxReturn.last, assigned_at: TaxReturn.last.updated_at),
        "UserMailer.incoming_interaction_notification_email [new_client_message]" => UserMailer.incoming_interaction_notification_email(client: Client.last, received_at: Time.now, user: User.last, interaction_count: 3, interaction_type: "new_client_message"),
        "UserMailer.incoming_interaction_notification_email [document_upload]" => UserMailer.incoming_interaction_notification_email(client: Client.last, received_at: Time.now, user: User.last, interaction_count: 3, interaction_type: "document_upload"),
        "UserMailer.incoming_interaction_notification_email [signed_8879]" => UserMailer.incoming_interaction_notification_email(client: Client.last, received_at: Time.now, user: User.last, interaction_count: 2, interaction_type: "signed_8879"),
        "VerificationCodeMailer.with_code" => VerificationCodeMailer.with(to: "example@example.com", locale: :en, service_type: :gyr, verification_code: '000000').with_code,
        "VerificationCodeMailer.no_match_found" => VerificationCodeMailer.no_match_found(to: "example@example.com", locale: :en, service_type: :gyr),
        "VerificationCodeMailer.archived_intake_verification_code" => VerificationCodeMailer.archived_intake_verification_code(to: "example@example.com", locale: :en, verification_code: '000000'),
        "DiyIntakeEmailMailer.high_support_message" => DiyIntakeEmailMailer.high_support_message(diy_intake: DiyIntake.new(email_address: 'example@example.com', preferred_first_name: "Preferredfirstname")),
        "CtcSignupMailer.launch_announcement" => CtcSignupMailer.launch_announcement(email_address: "example@example.com", name: "Preferredfirstname")
      }

      emails.merge(automated_messages_and_mailers).transform_values do |message|
        ActionMailer::Base.preview_interceptors.each do |interceptor|
          interceptor.previewing_email(message)
        end
        message
      end
    end
  end
end
