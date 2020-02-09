class SendSpouseVerificationRequestJob < ApplicationJob
  queue_as :default

  def perform(verification_request_id)
    verification_request = SpouseVerificationRequest.find(verification_request_id)
    if verification_request.zendesk_ticket_id.blank?
      service = ZendeskSpouseVerificationService.new(verification_request)
      if verification_request.zendesk_requester_id.blank?
        verification_request.update(zendesk_requester_id: service.create_verification_request_ticket_requester)
      end
      verification_request.update(zendesk_ticket_id: service.create_verification_request_ticket)
    end
  end
end
