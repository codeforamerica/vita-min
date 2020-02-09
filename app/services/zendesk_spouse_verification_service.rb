class ZendeskSpouseVerificationService
  include ZendeskServiceHelper
  include ZendeskPartnerHelper

  def initialize(verification_request)
    @verification_request = verification_request
    @intake = verification_request.intake
  end

  def create_verification_request_ticket_requester
    # returns the Zendesk ID of the created user
    find_or_create_end_user(
      nil,
      @verification_request.email,
      @verification_request.phone_number,
      exact_match: true
    )
  end

  def create_verification_request_ticket
    create_ticket(
      subject: "#{@intake.primary_user.full_name}'s link sent to spouse",
      requester_id: @verification_request.zendesk_requester_id,
      group_id: group_id_for_state,
      body: message_body,
      public: true,
      tags: ["outgoing_sms"]
    )
  end

  def message_body
    <<~BODY
      #{@intake.primary_user.full_name} is requesting to file their taxes with you. In order to proceed with your joint taxes, we'll need to verify your identity
      
      Please verify your identity with this link:
      https://www.vitataxhelp.org/questions/identity
    BODY
  end
end