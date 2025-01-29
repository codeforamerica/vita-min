class SendDfTransferIssueMessageJob < ApplicationJob
  def perform(email: false, sms: false, contact_info: nil, state_code: nil)
    message_instance = StateFile::AutomatedMessage::DfTransferIssueMessage.new

    if email
      StateFileNotificationEmail.create!(
        data_source: nil, # we have no data source because the intakes have been deleted
        to: contact_info,
        body: message_instance.email_body(state_code: state_code),
        subject: message_instance.email_subject(state_code: state_code)
      )
    end
    if sms
      StateFileNotificationTextMessage.create!(
        data_source: nil, # we have no data source because the intakes have been deleted
        to_phone_number: contact_info,
        body: message_instance.sms_body(state_code: state_code),
      )
    end
  end

  def priority
    PRIORITY_MEDIUM
  end
end
