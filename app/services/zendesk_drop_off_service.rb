class ZendeskDropOffService
  include ZendeskServiceHelper
  include Rails.application.routes.url_helpers

  # Group IDs
  ORGANIZATION_GROUP_IDS = {
    "thc" => EitcZendeskInstance::TAX_HELP_COLORADO,
    "gwisr" => EitcZendeskInstance::GOODWILL_SOUTHERN_RIVERS,
    "uwba" => EitcZendeskInstance::UNITED_WAY_BAY_AREA,
    "uwco" => EitcZendeskInstance::UNITED_WAY_CENTRAL_OHIO,
    "fc" => EitcZendeskInstance::FOUNDATION_COMMUNITIES,
    "uwvp" => EitcZendeskInstance::UNITED_WAY_VIRGINIA,
    "cwf" => EitcZendeskInstance::CAMPAIGN_FOR_WORKING_FAMILIES,
  }.freeze

  def initialize(drop_off)
    @drop_off = drop_off
  end

  def instance
    EitcZendeskInstance
  end

  def create_ticket
    zendesk_user_id = find_or_create_end_user(@drop_off.name, @drop_off.email, @drop_off.standardized_phone_number)
    ticket = build_ticket(
      subject: @drop_off.name,
      requester_id: zendesk_user_id,
      group_id: group_id,
      external_id: @drop_off.external_id,
      body: comment_body,
      fields: {
          EitcZendeskInstance::CERTIFICATION_LEVEL => @drop_off.certification_level,
          EitcZendeskInstance::HSA => @drop_off.hsa,
          EitcZendeskInstance::INTAKE_SITE => intake_site_tag,
          EitcZendeskInstance::STATE => @drop_off.state,
          EitcZendeskInstance::INTAKE_STATUS => EitcZendeskInstance::INTAKE_STATUS_COMPLETE,
          EitcZendeskInstance::SIGNATURE_METHOD => @drop_off.signature_method
      }
    )
    success = ticket.save
    raise ZendeskServiceHelper::ZendeskAPIError.new("Error creating drop off ticket: #{ticket.errors}") unless success

    ticket.fields = { EitcZendeskInstance::LINK_TO_CLIENT_DOCUMENTS => zendesk_ticket_url(id: ticket.id) }
    update_success = ticket.save
    raise ZendeskServiceHelper::ZendeskAPIError.new(
      "Error updating drop off ticket document link: #{ticket.errors}"
    ) unless update_success

    return ticket.id
  end

  def append_to_existing_ticket
    ticket = ZendeskAPI::Ticket.find(client, id: @drop_off.zendesk_ticket_id)
    ticket.comment = { body: comment_body }

    success = ticket.save
    raise ZendeskServiceHelper::ZendeskAPIError.new("Error updating drop off ticket: #{ticket.errors}") unless success

    success
  end

  def comment_body
    <<~BODY
      New Dropoff at #{@drop_off.intake_site}

      Certification Level: #{@drop_off.certification_level}#{" and HSA" if @drop_off.hsa}
      Name: #{@drop_off.name}
      Phone number: #{@drop_off.formatted_phone_number}
      Email: #{@drop_off.email}
      Signature method: #{@drop_off.formatted_signature_method}#{pickup_date_line}
      State (for state tax return): #{@drop_off.state_name}
      Additional info: #{@drop_off.additional_info}
    BODY
  end

  private

  def intake_site_tag
    @drop_off.intake_site.downcase.gsub(/[ –-]/, "_") # that's a dash and an emdash, folks
  end

  def pickup_date_line
    "\nPickup Date: #{I18n.l(@drop_off.pickup_date)}" if @drop_off.pickup_date
  end

  def group_id
    ORGANIZATION_GROUP_IDS[@drop_off.organization]
  end
end
